#' Harmonise images sizes
#'
#' @param x File path to an image.
#' @param type Either "full" (the default) for a 1,600px-wide image or "side"
#'   for a 300px-wide image.

harmonise_image_sizes <- function (x, type = "full") {

  size <- ifelse(type == "side", 300, 1600)

  purrr::walk(x, function (y) {

    # Load image and get size
    image <- magick::image_read(y)
    image_info <- magick::image_info(image)

    # Resize image
    if (image_info$width >= image_info$height) {
      if (image_info$width > size)
        image <- magick::image_resize(image, geometry = size)
    } else {
      if (image_info$height > size)
        image <- magick::image_resize(image, geometry = paste0("x", size))
    }

    # Save resized image
    magick::image_write(image, path = y, density = "72x72")

  })

}
