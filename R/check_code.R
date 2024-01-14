#' Check code file before submission
#'
#' Check your code to identify various common issues with code content, code
#' style, etc.
#'
#' @param file A file path for the .R file to check
#' @param reprex Should the code be checked for errors?
#' @param style Should the code be checked for style issues?
#' @return NULL, invisibly
#' @export
check_code <- function(
    file,
    reprex = TRUE,
    style = TRUE
) {

  # Check installed packages
  rlang::check_installed("cli", reason = "to print results of checks")
  rlang::check_installed("dplyr", reason = "to manage test results")
  rlang::check_installed("lintr", reason = "to test code style")
  rlang::check_installed("reprex", reason = "to test code")

  # Check arguments
  if (!rlang::is_character(file, n = 1))
    rlang::abort("`file` must be a single file path")
  if (!file.exists(file))
    rlang::abort(paste("The file ", file, "cannot be found"))
  if (!rlang::is_logical(reprex, n = 1))
    rlang::abort("`reprex` must be a single `TRUE` or `FALSE` value")
  if (!rlang::is_logical(style, n = 1))
    rlang::abort("`style` must be a single `TRUE` or `FALSE` value")

  # Introduce
  cli::cli_h1("Checking your code")
  cli::cli_text(
    "Your code will be checked for errors, warnings and other issues. This ",
    "will take anywhere from a few seconds to several minutes, depending on ",
    "how long your code takes to run."
  )

  # Check for errors
  if (reprex) {

    # Copy file to temporary location for reprexing
    reprex_file <- tempfile(fileext = ".R")
    if (!file.copy(from = file, to = reprex_file))
      cli::cli_abort("Cannot copy `file` to temporary directory for processing")

    # Reprex file
    rlang::try_fetch(
      suppressMessages(
        reprex::reprex(input = reprex_file, venue = "r", html_preview = FALSE)
      ),
      error = function(cnd) {
        cli::cli_h2("There is an error in your code")
        cli::cli_abort("Details of the error:", parent = cnd)
      }
    )

    # Load reprex file
    reprex_text <- readLines(sub("\\.R$", "_reprex.r", reprex_file))

    # Report any issues
    if (any(grepl("^#> Error", reprex_text))) {

      cli::cli_h2("There appear to be errors in your code")
      cli::cli_text("You must fix these errors before continuing.")
      cli::cli_text("The first error was:")
      cli::cli_ul()
      cli::cli_li(head(
        sub(
          "^#> Error in ",
          "",
          grep("^#> Error", reprex_text, value = TRUE)
        ),
        1
      ))
      cli::cli_end()
      cli::cli_text("There may be further errors after this.")
      cli::cli_text(
        "Click the link below and look for lines that begin with \"#> Error\" ",
        "to see more details."
      )

    } else if (any(grepl("^#> Warning", reprex_text))) {

      warnings_found <- sub(
        "^#> Warning: ",
        "",
        grep("^#> Warning", reprex_text, value = TRUE)
      )

      warnings_found <- ifelse(
        length(warnings_found) >= 3,
        head(warnings_found, 3),
        warnings_found
      )

      cli::cli_h2("Warnings were produced by your code")
      cli::cli_text(
        "Although your code appears to run without errors, your code does ",
        "produce one or more warnings. You should make sure you understand ",
        "these warnings and whether you need to take any action before you ",
        "continue."
      )
      cli::cli_text(ifelse(
        length(warnings_found) > 1,
        paste("The first ", length(warnings_found), "warnings were:"),
        "The warning was:"
      ))
      cli::cli_ul(warnings_found)
      cli::cli_text(
        "Click the link below and look for lines that begin with ",
        "\"#> Warning\" to see more details."
      )

    } else {

      cli::cli_h2("No errors were found in your code")
      cli::cli_text(
        "There may still be issues in your code that could not be detected by ",
        "this check. Click the link below and look for any unexpected output. ",
        "Make sure you make any changes in your original code file."
      )

    }

    cli::cli_text("{.file ", sub("\\.R$", "_reprex.r", reprex_file), "}")

  }

  # Check code style
  if (style) {

    lint_results <- lintr::lint(
      file,
      linters = list(
        # Default linters (with some excluded)
        lintr::assignment_linter(),
        lintr::brace_linter(),
        lintr::commas_linter(),
        lintr::commented_code_linter(),
        lintr::equals_na_linter(),
        lintr::function_left_parentheses_linter(),
        lintr::infix_spaces_linter(),
        lintr::line_length_linter(),
        lintr::no_tab_linter(),
        lintr::object_length_linter(),
        lintr::object_name_linter(),
        lintr::paren_body_linter(),
        lintr::pipe_continuation_linter(),
        lintr::semicolon_linter(),
        lintr::seq_linter(),
        lintr::single_quotes_linter(),
        lintr::spaces_inside_linter(),
        lintr::spaces_left_parentheses_linter(),
        lintr::T_and_F_symbol_linter(),
        lintr::vector_logic_linter(),
        # Non-default linters
        lintr::absolute_path_linter(),
        lintr::duplicate_argument_linter(),
        lintr::missing_argument_linter(),
        lintr::missing_package_linter(),
        lintr::numeric_leading_zero_linter(),
        lintr::undesirable_function_linter(
          fun = lintr::modify_defaults(
            lintr::all_undesirable_functions,
            library = NULL,
            source = NULL
          )
        ),
        lintr::unused_import_linter(allow_ns_usage = TRUE)
      ),
      cache = FALSE
    ) |>
      as.data.frame() |>
      dplyr::group_by(.data$message) |>
      dplyr::summarise(
        line_sort = dplyr::first(.data$line_number),
        line_count = length(.data$line_number),
        line_nums = list(.data$line_number)
      ) |>
      dplyr::arrange(.data$line_sort) |>
      dplyr::select(.data$message, .data$line_nums)

    if (length(lint_results$message) > 0) {
      cli::cli_h2("There are potential issues with your code style")
      cli::cli_text("You should check each of these issues before continuing:")
      cli::cli_ul()
      format_lintr_message(lint_results$message, lint_results$line_nums)
      cli::cli_end()
    }

  }

  if (!reprex && !style) {
    cli::cli_warn(paste(
      "No checking was done because both the {.code reprex} and {.code style}",
      "arguments were set to {.code FALSE}."
    ))
  } else {
    cli::cli_text(
      "{.emph You should run {.fn check_code} again after making any changes.}"
    )
  }

  invisible()

}

format_lintr_message <- Vectorize(function(message, line_nums) {

  # Remove the terminal period
  message <- substr(message, 1, nchar(message) - 1)

  # Change message if needed
  if (message == "Lines should not be more than 80 characters")
    message <- paste(
      "Lines should not be more than 80 characters (ignore this message if the",
      "lines contain long URLs or file paths)"
    )

  # Print single/plural message
  if (length(line_nums) == 1) {
    cli::cli_li("{message} on line {line_nums}")
  } else {
    cli::cli_li("{message} on lines {line_nums}")
  }

})
