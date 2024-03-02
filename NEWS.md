# crimemapping 2.7.0

* Update content for 2024 Week 8 (tutorials 14 and 15).


# crimemapping 2.6.0

* Update content for 2024 Week 7 (tutorials 12 and 13).


# crimemapping 2.5.1

* Remove `leaflet` map from tutorial 10, since this was again causing the 
  `` Couldn't normalize path in `addResourcePath` `` error.


# crimemapping 2.5.0

* Update content for 2024 Week 6 (tutorials 10 and 11).


# crimemapping 2.4.1

* Remove undeclared dependency on `stringr` package in `check_code()`.


# crimemapping 2.4.0

* Release `check_code()` function.


# crimemapping 2.3.2

* Remove reference to obsolete Stamen map tile provider in tutorial 9.
* Make minor changes to background code consequent to updating the book versions
  of each tutorial.


# crimemapping 2.3.1

* Remove interactivity from leaflet portion of tutorial 9 due to 
`` Couldn't normalize path in `addResourcePath` `` error.


# crimemapping 2.3.0

* Update content for 2024 Week 4 (tutorials 8 and 9).


# crimemapping 2.2.0

* Update content for 2024 Week 3 (tutorials 6 and 7).


# crimemapping 2.1.1

* Fix bug in which the `progress` argument to `annotation_map_tile()` was 
  incorrectly set to `FALSE` instead of `"none"`.


# crimemapping 2.1.0

* Update content for 2024 Week 2 (tutorials 4 and 5).


# crimemapping 2.0.0

* Update content for 2024 Week 1 (tutorials 1, 2 and 3).


# crimemapping 1.8.0

* Update content for 2023 Week 9 (tutorial 16).


# crimemapping 1.7.1

* Remove `case_match()` function from Tutorial 15, since it is only available in
  the latest version of `dplyr`.


# crimemapping 1.7.0

* Update content for 2023 Week 8 (tutorials 14 and 15).


# crimemapping 1.6.0

* Update content for 2023 Week 7 (tutorials 12 and 13).


# crimemapping 1.5.0

* Update content for 2023 Week 6 (tutorials 10 and 11).


# crimemapping 1.4.0

* Added `check_code()` function.


# crimemapping 1.3.0

* Updated content for 2023 Week 4 (tutorials 8 and 9).


# crimemapping 1.2.2

* `update()` function re-written to allow longer for download and provide more
  useful messages to users.
* Remove Queensland and Uttar Pradesh data that has been moved to the 
  crimemappingdata package.


# crimemapping 1.2.1

* Fixed outdated URL for the aggravated assaults dataset in tutorial 3.


# crimemapping 1.2.0

* Update content for 2023 Week 3 (tutorials 6 and 7).
* Remove some datasets that have now been moved to the crimemappingdata package.


# crimemapping 1.1.0

* Update content for 2023 Week 2 (tutorials 4 and 5).


# crimemapping 1.0.0

* Update content for 2023 Week 1 (tutorials 1, 2 and 3).


# crimemapping 0.14.0

* Update content for Week 9 (tutorial 16).


# crimemapping 0.13.0

* Update content for Week 8 (tutorials 14 and 15).


# crimemapping 0.12.0

* Update content for Week 7 (tutorials 12 and 13).


# crimemapping 0.11.0

* Update content for Week 6 (tutorials 10 and 11).


# crimemapping 0.8.0

* Added content for Week 9, including a tutorial on Mapping 'Mapping crime over 
  time' and data on aggravated assaults in Chicago.


# crimemapping 0.7.0

* Added content for Week 8, including tutorials on 'Writing reports in R' and
  'Presenting spatial data without maps' as well as several new datasets.


# crimemapping 0.6.2

* Fixed a problem in which some users found the `burglary_values` object was
  missing in tutorial 12.


# crimemapping 0.6.1

* Fixed a problem in which some users found the `monthly_counts` object was
  not found in tutorial 12.


# crimemapping 0.6.0

* Added content for Week 7, including tutorials on 'Handling messy data' and
  'Mapping crime series' as well as data for addresses in Chicago for geocoding.


# crimemapping 0.5.2

* Fixed a problem in which some users were unable to access objects within 
  tutorial 11 that relied on daisy-chaining of learnr chunks via the 
  exercise.setup chunk option, so moved the necessary objects into the setup
  chunk.


# crimemapping 0.5.1

* Fixed a mistake in the 'Using data about places' tutorial that caused an error
  when trying to unzip a file to a specific directory.


# crimemapping 0.5.0

* Added content for Week 6, including tutorials on 'Using data about places' and
  'Mapping hotspots' as well as data for various offences in Nottingham and
  personal robberies in Toronto.
* Began roll-out of new UCL theme for tutorials.
* Began to speed up tutorial loading by pre-processing code that produces static 
  images in tutorials so that it only needs to be run at run-time if the 
  relevant static image is not present.
* Added data for anti-social behaviour in Northumbria.
* Added installation instructions to README.


# crimemapping 0.4.0

* Added content for Week 4, including tutorials on 'Handling bugs in your code'
  and 'Mapping area data' as well as data for frauds in Kansas City, road deaths
  in the United Kingdom, murders in Uttar Pradesh and stalking in Queensland.
* Removed need for user to download Natural Earth data when launching the 
  'Wrangling data' tutorial if the resulting map already exists as an image file
  (which it should do).
* Added a `NEWS.md` file to track changes to the package.


# crimemapping 0.3.0

* Added content for Week 3, including tutorials on 'Code with style' and 'Giving
  a map content' as well as data for shootings in New York City.


# crimemapping 0.2.1


# crimemapping 0.2.0


# crimemapping 0.1.0
