# ==============================================================================
# 01_fetch_pjm.R -- wholesale LMPs from PJM Data Miner 2.0 (PUBLIC)
# ==============================================================================
# Source: PJM Data Miner 2.0 API (free subscription key in PJM_API_KEY).
#   https://dataminer2.pjm.com/  -- da_hrl_lmps / rt_hrl_lmps feeds.
# Plan: hourly zonal LMPs (DOM zone = treatment) -> monthly averages.
# Output: data/raw/pjm_lmp_*.parquet; data/tidy/lmp_zone_month.parquet
# ==============================================================================
source(if (file.exists("scripts/R/00_setup.R")) "scripts/R/00_setup.R" else if (file.exists("00_setup.R")) "00_setup.R" else file.path(Sys.getenv("RGGI_ROOT"), "scripts", "R", "00_setup.R"))

PJM_ZONES <- c("DOM", "AEP", "APS", "ATSI", "BGE", "COMED", "DAY", "DEOK",
               "DPL", "DUQ", "EKPC", "JCPL", "METED", "PECO", "PENELEC",
               "PEPCO", "PPL", "PSEG", "RECO")

fetch_pjm_lmps <- function(start = SAMPLE_START, end = SAMPLE_END, dest = DIRS$data_raw) {
  # TODO(when key exists): page through Data Miner 2 API; write parquet by month.
  stop("Requires PJM_API_KEY (free): register at https://dataminer2.pjm.com, ",
       "create a subscription key at apiportal.pjm.com, then ",
       "`export PJM_API_KEY=...` and implement this fetcher.")
}

if (sys.nframe() == 0) {
  message("[01_fetch_pjm] SKIPPED -- no PJM_API_KEY set (free key: ",
          "register at dataminer2.pjm.com / apiportal.pjm.com). ",
          "Panel carries lmp = NA until then; wholesale results are pending.")
}
