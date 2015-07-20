# Multicon
###A Ruby implementation of multiple contingency analysis

multicon computes a contingency table comparing n raters to a gold standard

Version: 0.1a

Developer: Jared Shenson

Email: jared [dot] shenson [at] gmail

###Usage
```ruby multicon.rb goldstd.csv rater1.csv [rater2.csv...]```

###Output
```multicon_r[# of raters]_[timestamp].csv```

###Notes
- Files must be saved as __CSV__, one column per possible code, one row per segment. See sample datafile.
- Cell contents must be 0 or 1, indicating absence (0) or presence (1) of given code.
- A single header row containing the codes used may be included. It will be auto-detected and used in the program's output.
- May use as many raters as desired
- Requires gem "Statsample" for calculation of kappa significance
