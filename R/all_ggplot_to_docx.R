#' Save all ggplot in a pptx
#'
#' @param out output file name
#' @param open booleen open file after creation
#' @param png booleen also save as png
#' @param global booleen use .GlobalEnv
#' @param folder png's folder
#'
#' @importFrom  officer read_pptx ph_with add_slide ph_location_type
#' @importFrom ggplot2 ggsave is.ggplot
#' @importFrom assertthat assert_that has_extension
#' @importFrom utils browseURL
#' @importFrom rvg dml
#'
#' @return NULL
#' @encoding UTF-8
#' @export
#'
#' @examples
#' \dontrun{
#' all_ggplot_to_pptx()
#' }
all_ggplot_to_pptx <- function(out = "tous_les_graphs.pptx", open = TRUE, png = TRUE, folder = "dessin", global = TRUE) {
  assert_that(has_extension(out, "pptx"))
  try(dir.create(folder, recursive = TRUE), silent = TRUE)
  # doc <- pptx( title = "title" )
  doc <- read_pptx()
  if (global) {
    lenv <- .GlobalEnv
  } else {
    lenv <- parent.frame()
  }
  laliste <- ls(envir = lenv)

  for (k in laliste) {
    if (is.ggplot(
      # eval(envir = lenv,parse(text=k))
      get(k, envir = lenv)
    )) {
      # doc <- addSlide( doc, slide.layout = "Title and Content" )
      doc <- doc %>%
        add_slide(layout = "Title and Content", master = "Office Theme") %>%
        ph_with(dml(ggobj = get(k, envir = lenv)), location = ph_location_type(type = "body"))

      if (png) {
        ggsave(
          # eval(envir = lenv,parse(text=k))
          get(k, envir = lenv),
          filename = paste0(folder, "/", k, ".png"), height = 15, width = 23
        )
      }
    }

    # on gere les ggsurvfit
    if (class(get(k, envir = lenv))[1] == "ggsurvplot") {
      doc <- doc %>%
        add_slide(layout = "Title and Content", master = "Office Theme") %>%
        ph_with(dml(ggobj = get(k, envir = lenv)$plot), location = ph_location_type(type = "body"))

      if (png) {
        ggsave(eval(envir = lenv, parse(text = k))$plot, filename = paste0(folder, "/", k, ".png"), height = 15, width = 23)
      }
    }
  }
  print(doc, target = out)
  if (open) {
    browseURL(out)
  }
  invisible()
}
