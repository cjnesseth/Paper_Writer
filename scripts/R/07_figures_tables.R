# ==============================================================================
# 07_figures_tables.R -- render manuscript figures (.pdf) and tables (.tex)
# ==============================================================================
# Consumes saved result objects (data/results/*.rds) and writes:
#   Figures/scm_gap_<event>_<outcome>.pdf   (SCM gap plots)
#   Figures/eventstudy_<event>_<outcome>.pdf (DiD coefficient plots)
#   Figures/placebo_<event>_<outcome>.pdf    (placebo distributions)
#   Tables/tab_main_<event>.tex              (modelsummary / fixest::etable)
#   Tables/tab_data_sources.tex              (from a config; replaces placeholder)
# The manuscript pulls these in via \includegraphics / \input. No hand-entered numbers.
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

save_fig <- function(plot, name, width = 6.5, height = 4) {
  ggsave(file.path(DIRS$figures, paste0(name, ".pdf")), plot,
         width = width, height = height, device = cairo_pdf)
}

make_data_sources_table <- function() {
  # TODO(Phase 2-3): render Tables/tab_data_sources.tex from the data-source config
  #   (kableExtra/modelsummary) with access dates/vintages, replacing the placeholder.
  message("Not implemented (Phase 2-3): regenerate tab_data_sources.tex.")
}

# Figures/tables generated in Phases 3-4 once estimation objects exist.
if (sys.nframe() == 0) message("[07_figures_tables] stub -- implement in Phase 3-4.")
