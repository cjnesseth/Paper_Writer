## ============================================================================
## 10_map_figure.R
## Geographic overview: DC locations + residential transactions colored by
## ring assignment (distance to nearest DC). Shows how ring-based treatment
## varies across space rather than around a single anchor point.
## ============================================================================

set.seed(20260330)
library(dplyr)
library(ggplot2)
library(jsonlite)
library(here)

proc_dir <- here::here("explorations", "data_collection", "processed")
fig_dir  <- here::here("Figures")

primary_blue  <- "#012169"
primary_gold  <- "#f2a900"
accent_gray   <- "#525252"
negative_red  <- "#b91c1c"

`%||%` <- function(a, b) if (is.null(a)) b else a

# --- Load DC centroids (with permit dates) ---
j <- read_json(file.path(proc_dir, "dc_centroids.geojson"), simplifyVector = FALSE)
dc_pts <- do.call(rbind, lapply(j$features, function(f) {
  data.frame(
    lon = f$geometry$coordinates[[1]],
    lat = f$geometry$coordinates[[2]],
    project = f$properties$project %||% NA_character_,
    earliest_permit = f$properties$earliest_permit %||% NA_character_,
    stringsAsFactors = FALSE
  )
}))
dc_pts$permit_year <- as.integer(substr(dc_pts$earliest_permit, 1, 4))

# --- Load residential transactions; classify each by ring ---
panel <- read.csv(file.path(proc_dir, "property_transactions_panel.csv"),
                   colClasses = c(parid = "character"))

panel$ring <- with(panel, ifelse(within_1km, "0-1 km",
                        ifelse(within_2km, "1-2 km",
                          ifelse(within_4km, "2-4 km", "4+ km"))))
panel$ring <- factor(panel$ring, levels = c("0-1 km", "1-2 km", "2-4 km", "4+ km"))

# Thin to ~15% for legibility but keep all close-ring points visible
panel_close <- panel %>% filter(ring %in% c("0-1 km", "1-2 km", "2-4 km"))
panel_far   <- panel %>% filter(ring == "4+ km") %>%
                 slice_sample(prop = 0.15)
panel_thin <- bind_rows(panel_close, panel_far)

# --- Plot ---
km_per_deg_lat <- 111
km_per_deg_lon <- 111 * cos(39 * pi / 180)

# Ring palette: red to gray as distance increases
ring_colors <- c(
  "0-1 km" = "#b91c1c",
  "1-2 km" = "#f2a900",
  "2-4 km" = "#0ea5e9",
  "4+ km"  = "grey40"
)
ring_alphas <- c("0-1 km" = 0.85, "1-2 km" = 0.70,
                 "2-4 km" = 0.55, "4+ km" = 0.35)
ring_sizes  <- c("0-1 km" = 0.55, "1-2 km" = 0.45,
                 "2-4 km" = 0.35, "4+ km" = 0.25)

# Draw far ring first (background), then closer rings on top
plot_order <- c("4+ km", "2-4 km", "1-2 km", "0-1 km")
panel_thin$ring <- factor(panel_thin$ring, levels = plot_order)
panel_thin <- panel_thin[order(panel_thin$ring), ]

# County boundary: fill all zoning polygons with a uniform light color and no
# internal borders. The filled area traces the actual county shape.
zone_polys <- readRDS(file.path(proc_dir, "zoning_polygons_official.rds"))

p_map <- ggplot() +
  geom_polygon(data = zone_polys,
               aes(x = lon, y = lat, group = group),
               fill = "grey93", color = "grey60", linewidth = 0.05) +
  geom_point(data = panel_thin,
             aes(x = lon, y = lat, color = ring, alpha = ring, size = ring)) +
  geom_point(data = dc_pts, aes(x = lon, y = lat),
             shape = 22, fill = "black", color = "white",
             size = 1.8, stroke = 0.3) +
  scale_color_manual(values = ring_colors, name = "Distance to nearest DC",
                      breaks = c("0-1 km", "1-2 km", "2-4 km", "4+ km")) +
  scale_alpha_manual(values = ring_alphas, guide = "none") +
  scale_size_manual(values = ring_sizes, guide = "none") +
  guides(color = guide_legend(override.aes =
    list(size = 2.5, alpha = c(0.85, 0.70, 0.55, 0.50)))) +
  coord_fixed(ratio = km_per_deg_lat / km_per_deg_lon) +
  labs(x = "Longitude", y = "Latitude") +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "right",
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.2)
  )

ggsave(file.path(fig_dir, "fig_map.pdf"), p_map,
       width = 9, height = 6.5, bg = "transparent")
message("Saved fig_map.pdf")
message("  DCs plotted: ", nrow(dc_pts))
message("  Transactions plotted: ", nrow(panel_thin),
        " (of ", nrow(panel), " total)")
message("  Ring counts (full panel):")
print(table(panel$ring))
