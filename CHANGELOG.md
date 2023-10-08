# Changelog

- fix: [#3] "No data available for steady state settings"
  - depending on x-axis selection the measurements are prefiltered to avoid
    the annoying error message in common use cases
- new: improved data import workflow
  - import can now do multiple files at a time
  - the whole process is within same uifigure
  - button that opens the selected parser for editing
    (in case something has to be changed)