---
name: "Pre-flight checklist: chapter XX, YYYY"
about: Checklist of actions required before a tutorial is published
title: ''
labels: Release
assignees: mpjashby

---

- [ ] Add walk-through videos
- [ ] Add multiple-choice questions at the end of each section
- [ ] Add short-answer revision questions at the end of the chapter
- [ ] Add further reading
- [ ] Add long abstract
- [ ] Add cross-reference handle for chapter
- [ ] Add chapter to `contents.qmd`
- [ ] Make sure chapter starts with the final map that we'll create
- [ ] Make sure chapter finishes with a complete script
- [ ] Check `aes()` inside `ggplot()` (rather than inside `geom_*()`) is instead in the form `ggplot() + aes()`
- [ ] Reduce image sizes using `harmonise_image_sizes()`
- [ ] Remove `source(here::here("mask_learnr_functions.R"))` from setup chunk
- [ ] Load packages with `pacman::p_load()` instead of `library()`
- [ ] `Cmd+F` to replace any reference to 'tutorial' with 'chapter'
- [ ] Spell check
- [ ] Build chapter
- [ ] Update Moodle
