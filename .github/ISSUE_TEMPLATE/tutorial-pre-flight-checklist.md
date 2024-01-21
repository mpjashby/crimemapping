---
name: "Pre-flight checklist: tutorial XX, YYYY"
about: Checklist of actions required before a tutorial is published
title: ''
labels: Release
assignees: mpjashby

---

- [ ] Add walk-through videos
- [ ] Add questions
- [ ] Add further reading
- [ ] Make sure tutorial (or section) starts with the final map that we'll create
- [ ] Make sure tutorial finishes with a complete script
- [ ] Replace `ifelse()` with `if_else()` (Ctrl+F)
- [ ] Replace `st_read()` with `read_sf()` (Ctrl+F)
- [ ] Add `progress = "none"` to `annotation_map_tile()` (Ctrl+F)
- [ ] Replace separate cartoon acknowledgements with a single acknowledgement of `<p class="credits"><a href="https://twitter.com/allison_horst">Artwork by @allison_horst</a></p>` on the final page
- [ ] Reduce image sizes using `harmonise_image_sizes()`
- [ ] Spell check
- [ ] Add `css: ["css/tutorial_style.css", "css/2024.css"]`
- [ ] Check tutorial is not included in `.Rbuildignore`
- [ ] Increment package version number
- [ ] Add description of update to `NEWS.md`
- [ ] Check all code in RStudio Server
- [ ] Update Moodle
