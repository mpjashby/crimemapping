#' Check code file before submission
#'
#' Check your code to identify various common issues with code content, code
#' style, etc.
#'
#' @param file A file path for the .R file to check, or \code{NULL} to choose a
#'   file using the standard system file select dialog box
#' @param reprex Should the code be checked for errors?
#' @param style Should the code be checked for style issues?
#' @return NULL, invisibly
#'
#' @importFrom rlang .data
#' @export
check_code <- function(
    file = NULL,
    reprex = TRUE,
    style = TRUE
) {

  # Check installed packages
  rlang::check_installed("cli", reason = "to print results of checks")
  rlang::check_installed("dplyr", reason = "to manage test results")
  rlang::check_installed(
    "lintr",
    reason = "to test code style",
    version = "3.1.1"
  )
  rlang::check_installed("reprex", reason = "to test code")

  # Load file if necessary
  if (rlang::is_null(file)) file <- file.choose()

  # Check arguments
  if (!rlang::is_character(file, n = 1) && !rlang::is_null(file))
    cli::cli_abort("`file` must be `NULL` or a single file path")
  if (!file.exists(file))
    cli::cli_abort(paste("The file ", file, "cannot be found"))
  if (!rlang::is_logical(reprex, n = 1))
    cli::cli_abort("`reprex` must be a single `TRUE` or `FALSE` value")
  if (!rlang::is_logical(style, n = 1))
    cli::cli_abort("`style` must be a single `TRUE` or `FALSE` value")
  file_type <- file |>
    stringr::str_extract(
      stringr::regex("\\.(r|rmd|qmd)$", ignore_case = TRUE)
    ) |>
    stringr::str_to_lower()
  if (!file_type %in% c(".r", ".rmd", ".qmd")) {
    cli::cli_abort(
      "`file` must be an R (`.R`), Rmarkdown (`.Rmd`) or Quarto (`.qmd`) "
    )
  }

  # Introduce
  cli::cli_h1("Checking your code")

  # Explain processing of Rmarkdown/Quarto documents
  if (file_type %in% c(".rmd", ".qmd")) {

    # cli tries to interpret `{r}` as an R object called `r`, so to avoid an
    # `object 'r' not found` error we have to create an object called `r`
    r <- "{r}"
    cli::cli_text(
      "{.emph Note}: The file you want to check appears to be a Quarto or ",
      "Rmarkdown file. This file will be checked by extracting the R code ",
      "from all the code chunks in the file (i.e. pieces of code with ```{r} ",
      "on a line before and ``` on a line afterwards). Any inline R code ",
      "(e.g. `r Sys.date()`) cannot be checked by this function. You can ",
      "check inline code by clicking the `Render` button at the top of your ",
      "Quarto document in RStudio."
    )

    r_file <- suppressMessages(knitr::purl(file, documentation = 0))
    file_loc <- stringr::str_glue("{dirname(file)}/{basename(r_file)}")
    file.rename(r_file, file_loc)
    file <- file_loc

  }

  # Check for errors
  if (reprex) {

    cli::cli_text(
      "Your code will be checked for errors, warnings and other issues. This ",
      "will take anywhere from a few seconds to several minutes, depending on ",
      "how long your code takes to run. Further messages will appear as the ",
      "checks run."
    )

    # Copy file to temporary location for reprexing
    reprex_file <- tempfile(fileext = ".R")
    if (!file.copy(from = file, to = reprex_file))
      cli::cli_abort("Cannot copy `file` to temporary directory for processing")

    # Reprex file
    rlang::try_fetch(
      suppressMessages(
        reprex::reprex(input = reprex_file, venue = "r") #, html_preview = FALSE)
      ),
      error = function(cnd) {
        cli::cli_h2("There is an error in your code")
        cli::cli_abort("Details of the error:", parent = cnd)
      }
    )

    # Load reprex file
    reprex_text <- readLines(sub("\\.R$", "_reprex_r.R", reprex_file))

    # Report any issues
    if (any(grepl("^#> Error", reprex_text))) {

      cli::cli_h2("There appear to be errors in your code")
      cli::cli_text("{.strong You must fix these errors before continuing.}")
      cli::cli_text("The first error was:")
      cli::cli_ul()
      cli::cli_li(utils::head(
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
        "Click the link below and look for lines that begin with ",
        "{.code #> Error} to see more details."
      )

    } else if (any(grepl("^#> Warning", reprex_text))) {

      warnings_found <- sub(
        "^#> Warning: ",
        "",
        grep("^#> Warning", reprex_text, value = TRUE)
      )

      warnings_found <- ifelse(
        length(warnings_found) >= 3,
        utils::head(warnings_found, 3),
        warnings_found
      )

      cli::cli_h2("Warnings were produced by your code")
      cli::cli_text(
        "Although your code appears to run without errors, your code does ",
        "produce one or more warnings. {.emph You should make sure you ",
        "understand these warnings and whether you need to take any action ",
        "before you continue}."
      )
      cli::cli_text(ifelse(
        length(warnings_found) > 1,
        paste("The first ", length(warnings_found), "warnings were:"),
        "The warning was:"
      ))
      cli::cli_ul(warnings_found)
      cli::cli_text(
        "Click the link below and look for lines that begin with ",
        "{.code #> Warning} to see more details."
      )

    } else {

      cli::cli_h2("No errors were found in your code")
      cli::cli_text(
        "There may still be issues in your code that could not be detected by ",
        "this check. Click the link below and look for any unexpected output ",
        "(output is shown on lines starting with {.code #>}). Make sure you ",
        "make any changes in your {.strong original} code file."
      )

    }

    cli::cli_text("{.file ", sub("\\.R$", "_reprex_r.R", reprex_file), "}")

  }

  # Check code style
  if (style) {

    lint_results <- lintr::lint(
      file,
      linters = list(
        lintr::absolute_path_linter(), # no absolute paths
        lintr::assignment_linter(), # `<-` is used for assignment
        lintr::brace_linter(), # {} are correctly styled
        lintr::class_equals_linter(), # classes are checked for with `inherits()` not `==`
        lintr::commas_linter(), # commas are followed by spaces
        lintr::cyclocomp_linter(), # no expressions are very complicated
        lintr::duplicate_argument_linter(), # no duplicate arguments
        lintr::equals_na_linter(), # NAs are checked with `is.na()` not `==`
        lintr::for_loop_index_linter(), # input var is not overwritten as loop-index var
        lintr::function_left_parentheses_linter(), # no space before function ()
        lintr::implicit_assignment_linter(), # no assignment inside function args
        lintr::indentation_linter(), # consistent indentation
        lintr::infix_spaces_linter(), # spaces around operators
        lintr::inner_combine_linter(), # vectorised function not re-used for every element of vector
        # lintr::keyword_quote_linter(), # no unnecessary quoting of obj index
        lintr::length_test_linter(), # no mistakes with usage of `length()`
        lintr::library_call_linter(allow_preamble = FALSE), # packages loaded first
        lintr::line_length_linter(), # lines no more than 80 chrs
        lintr::missing_argument_linter(), # no empty function args
        lintr::missing_package_linter(), # no uninstalled packages
        lintr::namespace_linter(), # no uninstalled packages
        lintr::nested_ifelse_linter(), # no nested `ifelse()` calls
        lintr::numeric_leading_zero_linter(), # require leading zeros before `.`
        lintr::object_length_linter(length = 40), # no excessively long object names
        lintr::object_name_linter(), # object names follow style guide
        lintr::paren_body_linter(), # space after function ()
        lintr::paste_linter(), # `paste()` not misused
        lintr::pipe_consistency_linter(pipe = "|>"), # use base pipe
        lintr::pipe_continuation_linter(), # pipe split over lines properly
        lintr::quotes_linter(), # double quotes
        lintr::repeat_linter(), # no infinite loops
        lintr::scalar_in_linter(), # no use of `%in%` on single values
        lintr::semicolon_linter(), # no semi-colons
        lintr::seq_linter(), # no problems with `1:length()` etc.
        lintr::sort_linter(), # no common mistakes with vector sorting
        lintr::spaces_inside_linter(), # no spaces inside () or []
        lintr::spaces_left_parentheses_linter(), # space before ( except function calls
        lintr::sprintf_linter(), # no common mistakes with `sprintf()`
        lintr::system_file_linter(), # no use of `file.path()` in `system.file()`
        lintr::T_and_F_symbol_linter(), # `T`/`F` aren't used for `TRUE`/`FALSE`
        lintr::todo_comment_linter(), # no comments saying 'to do' or 'fix me'
        # no use of undesirable functions (except `library()`)
        lintr::undesirable_function_linter(
          fun = lintr::modify_defaults(
            defaults = lintr::default_undesirable_functions,
            library = NULL
          )
        ),
        lintr::undesirable_operator_linter(), # no use of undesirable operators
        lintr::unnecessary_concatenation_linter(), # no use of `c()` with empty args
        lintr::unnecessary_lambda_linter(), # no unnecessary anonymous functions
        lintr::unnecessary_nested_if_linter(), # no unnecessary nested ifs (shudder)
        lintr::unreachable_code_linter(), # no unreachable code
        lintr::unused_import_linter(), # no un-used packages loaded
        lintr::vector_logic_linter() # no problematic `&` or `|` in `if()` etc.
      ),
      cache = FALSE
    ) |>
      as.data.frame() |>
      dplyr::filter(
        !(linter == "line_length_linter" & stringr::str_detect(line, "http"))
      ) |>
      dplyr::mutate(
        message = dplyr::case_when(
          linter == "implicit_assignment_linter" ~
            "Do not assign values to objects inside function calls",
          linter == "indentation_linter" ~ "Indentation is incorrect",
          linter == "line_length_linter" ~
            "Lines should not be more than 80 characters unless they contain URLs or file paths",
          linter == "infix_spaces_linter" ~
            "Put a space either side of operators such as `+` and `<-`",
          TRUE ~ stringr::str_to_lower(stringr::str_remove(message, "\\.$"))
        )
      ) |>
      dplyr::group_by(.data$message) |>
      dplyr::summarise(
        line_sort = dplyr::first(.data$line_number),
        line_count = length(.data$line_number),
        line_nums = list(.data$line_number)
      ) |>
      dplyr::arrange(.data$line_sort) |>
      dplyr::select(.data$message, .data$line_nums)

    if (length(lint_results$message) > 0) {
      cli::cli_h2("{.strong There are potential issues with your code style}")
      cli::cli_text(
        "Code style is important because well-styled code is less likely to ",
        "contain logic errors that cannot be detected by this automated check."
      )
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

  # Print single/plural message
  if (length(line_nums) == 1) {
    cli::cli_li("Line {line_nums}: {message}")
  } else {
    cli::cli_li("Lines {line_nums}: {message}")
  }

})
