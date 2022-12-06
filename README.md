
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tilt.company.match

The goal of tilt.company.match is to provide helpers for company name
matching in the tilt-project,

## Installation

You can install the development version of tilt.company.match from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("2DegreesInvesting/tilt.company.match")
```

## Matching loanbooks to the tilt database

The matching problem is characterised as follows:

-   matching companies from banks\` loanbooks to tilt will face problems
    of inconsistent company names (typos, conventions…)

-   zip will be available as relatively reliable additional information

-   not all companies in loanbooks will be in tilt db (thus not have a
    match)

To match the companies provided in a loanbook to companies in the tilt
database we expect a loanbook dataframe and a tilt db dataframe that
hold at least the columns **company\_name**, **zip** and
**country**.Further columns that educate decisions made by humans in the
matching process may be present. For an example compare demo data below.

``` r
library(tilt.company.match)
knitr::kable(head(demo_loanbook))
```

|  id | company\_name          | zip   | country | misc\_info |
|----:|:-----------------------|:------|:--------|:-----------|
|   1 | Peasant Peter          | 01234 | germany | A          |
|   2 | Peasant Peter          | 01234 | germany | Z          |
|   3 | Peasant Peter          | 11234 | germany | Z          |
|   4 | Peasant Paul           | 01234 | germany | Z          |
|   5 | Bread Bakers Limited   | 23456 | germany | C          |
|   6 | Flower Power & Company | 34567 | germany | Z          |

### Pre-matching functions to check the data

I order to run the matching process optimally, here are some useful
functions to check your data before the matching process.

#### Report duplicates

The function **report\_duplicates** shows whether there are duplicates
on some columns of interest. In this case, we strongly suggest
duplicates on the **company\_name**, **zip** and **country** columns
combination. We strongly encourage to use it on the loanbook data set.

``` r
loanbook <- demo_loanbook
columns <- c("company_name", "zip", "country")

report_duplicates(loanbook, columns)
#> Found duplicate(s) on columns company_name, zip, country of the data set.
#> ✖ Found for the company Peasant Peter, zip: 01234, country: germany
#> ℹ Please check if these duplicates are intended and have an unique id.
```

Note: In our example we see, that while there are duplicate rows on
columns company\_name, zip, country they seem to do belong to different
companies so we do not need to fix this in our loanbook.

#### Report missing values

Missing values or NAs should not exist in neither the loanbook or tilt
data set. The function **report\_missings** checks how many NAs there
are in each columns of the data set and report them to the user.

Here, the tilt data set does not have any NAs so it should not throw any
error message.

``` r
tilt <- demo_tilt

report_missings(tilt)
#> No missings values found in the data.
```

Whereas if we insert random NAs in the dataset, the function should
report these latter and throw an error.

``` r
nr <- nrow(tilt)
nc <- ncol(tilt)

tilt_m <- tilt

tilt_m[sample(nr, 3), sample(nc, 2)] <- NA

# un-comment this line to have the error
# report_missings(tilt_m)
```

### Preprocessing

In a first step, the company\_names are preprocessed to reduce noise and
increase consistency. To this end we borrow a function from 2DII\`s
package r2dii.match. We assign the result of the preprocessing to a new
column **company\_alias**.

``` r
loanbook <- demo_loanbook %>% 
  dplyr::mutate(company_alias = r2dii.match:::to_alias(company_name))

knitr::kable(head(loanbook))
```

|  id | company\_name          | zip   | country | misc\_info | company\_alias  |
|----:|:-----------------------|:------|:--------|:-----------|:----------------|
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter    |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter    |
|   3 | Peasant Peter          | 11234 | germany | Z          | peasantpeter    |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul     |
|   5 | Bread Bakers Limited   | 23456 | germany | C          | breadbakers ltd |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co  |

``` r
tilt <- demo_tilt %>% 
  dplyr::mutate(company_alias = r2dii.match:::to_alias(company_name))

knitr::kable(head(tilt))
```

|  id | company\_name                | zip   | country | misc\_info | company\_alias        |
|----:|:-----------------------------|:------|:--------|:-----------|:----------------------|
|   1 | Peasant Peter                | 01234 | germany | A          | peasantpeter          |
|   2 | Peasant Peter                | 01234 | germany | Z          | peasantpeter          |
|   3 | Peasant Peter                | 11234 | germany | Z          | peasantpeter          |
|   4 | Peasant Paul                 | 01234 | germany | B          | peasantpaul           |
|   5 | The Bread Bakers Ltd         | 23456 | germany | C          | thebreadbakers ltd    |
|   6 | Flower Power Friends and Co. | 34567 | germany | D          | flowerpowerfriends co |

### Deriving Candidates

To identify which entries from the tilt db match to the companies in the
loanbook, we identify in a first step all companies with a matching
country and zip code. This is based on the assumptions that zip codes
are correct and stable.

``` r
loanbook_with_candidates <- loanbook %>% 
  dplyr::left_join(tilt, by = c("country", "zip"), suffix = c("", "_tilt"))

knitr::kable(head(loanbook_with_candidates))
```

|  id | company\_name | zip   | country | misc\_info | company\_alias | id\_tilt | company\_name\_tilt | misc\_info\_tilt | company\_alias\_tilt |
|----:|:--------------|:------|:--------|:-----------|:---------------|---------:|:--------------------|:-----------------|:---------------------|
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        1 | Peasant Peter       | A                | peasantpeter         |
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        2 | Peasant Peter       | Z                | peasantpeter         |
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        4 | Peasant Paul        | B                | peasantpaul          |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        1 | Peasant Peter       | A                | peasantpeter         |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        2 | Peasant Peter       | Z                | peasantpeter         |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        4 | Peasant Paul        | B                | peasantpaul          |

One can see that e.g. the company with the loanbook id 1 has 3 potential
matches in the tilt db that have the same zip (tilt id 1, 2, 4).

Next, we are calculating the string similarity between the aliased
company name in the loanbook with the aliased company names in the tilt
db in the same zip code and ordering by descending proximity. A complete
similarity corresponds to 1, complete dissimilarity corresponds to 0.
There are several string similarity metrics available with the
**stringdist**-package. Depending on the nature and generation modality
of the text different metrics perform best. For the current problem the
Jaro-Winkler metric with a prefix factor of 0.1 is chosen. This metric
tends to be suitable for comparing human typed text that might have
typos.

``` r
loanbook_with_candidates_and_dist <- loanbook_with_candidates %>% 
  dplyr::mutate(string_sim = stringdist::stringsim(a = .data$company_alias, b = .data$company_alias_tilt, method = "jw", p = 0.1)) %>% 
  dplyr::arrange(id, -string_sim)

knitr::kable(loanbook_with_candidates_and_dist)
```

|  id | company\_name          | zip   | country | misc\_info | company\_alias      | id\_tilt | company\_name\_tilt          | misc\_info\_tilt | company\_alias\_tilt  | string\_sim |
|----:|:-----------------------|:------|:--------|:-----------|:--------------------|---------:|:-----------------------------|:-----------------|:----------------------|------------:|
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 |
|   3 | Peasant Peter          | 11234 | germany | Z          | peasantpeter        |        3 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        4 | Peasant Paul                 | B                | peasantpaul           |   1.0000000 |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        1 | Peasant Peter                | A                | peasantpeter          |   0.8787879 |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        2 | Peasant Peter                | Z                | peasantpeter          |   0.8787879 |
|   5 | Bread Bakers Limited   | 23456 | germany | C          | breadbakers ltd     |        5 | The Bread Bakers Ltd         | C                | thebreadbakers ltd    |   0.8444444 |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        7 | Flower Power and Co.         | F                | flowerpower co        |   1.0000000 |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        6 | Flower Power Friends and Co. | D                | flowerpowerfriends co |   0.9333333 |
|   7 | Screwdriver Experts    | 45678 | germany | D          | screwdriverexperts  |       NA | NA                           | NA               | NA                    |          NA |
|   8 | Screwdriver Expert     | 45678 | germany | Z          | screwdriverexpert   |       NA | NA                           | NA               | NA                    |          NA |
|   9 | John Meier’s Groceries | 56789 | germany | E          | johnmeiersgroceries |        8 | John and Jacques Groceries   | E                | johnjacquesgroceries  |   0.8478947 |
|  10 | John Meier’s Groceries | 55555 | germany | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA |
|  11 | John Meier’s Groceries | 55555 | norway  | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA |

## Selecting matches

In order to make the work of a human working on the matching as easy as
possible what can be automated should be automated. However correct
matching is essential for the project success so incorrect matches,
which cannot ultimately be ruled out when matching automatically are not
acceptable. As a consequence for now the following workflow is
suggested.

A human coder will have to inspect the data. It is advisable do to so in
a spreadsheet application. A row is selected as match by setting column
**accept\_match** to TRUE. To support this the column **suggest\_match**
is provided.

The **suggest\_match** column is set to TRUE if:

-   The match is above a determined threshold.
-   It is the highest match of all matches.
-   There is only 1 highest match per **company\_name** x **id**
    combination to avoid duplicates.

``` r
highest_matches_per_company <- loanbook_with_candidates_and_dist %>% 
  dplyr::group_by(id) %>% 
  dplyr::filter(string_sim == max(string_sim))

threshold <- 0.9 # Threshold decided upon extensive experience with r2dii.match function and processes  

highest_matches_per_company_above_thresh <- highest_matches_per_company %>%
  dplyr::filter(string_sim > threshold) 

highest_matches_per_company_above_thresh_wo_duplicates <- highest_matches_per_company_above_thresh %>%
  dplyr::mutate(duplicates = any(duplicated(company_name, zip))) %>%
  dplyr::filter(duplicates == FALSE) %>% 
  dplyr::select(id, id_tilt) %>% 
  dplyr::mutate(suggest_match = TRUE)
  
loanbook_with_candidates_and_dist_and_suggestion <- loanbook_with_candidates_and_dist %>% 
  dplyr::left_join(highest_matches_per_company_above_thresh_wo_duplicates, by = c("id", "id_tilt")) %>% 
  dplyr::mutate(accept_match = NA)

knitr::kable(loanbook_with_candidates_and_dist_and_suggestion)
```

|  id | company\_name          | zip   | country | misc\_info | company\_alias      | id\_tilt | company\_name\_tilt          | misc\_info\_tilt | company\_alias\_tilt  | string\_sim | suggest\_match | accept\_match |
|----:|:-----------------------|:------|:--------|:-----------|:--------------------|---------:|:-----------------------------|:-----------------|:----------------------|------------:|:---------------|:--------------|
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | NA            |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | NA            |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   3 | Peasant Peter          | 11234 | germany | Z          | peasantpeter        |        3 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | TRUE           | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        4 | Peasant Paul                 | B                | peasantpaul           |   1.0000000 | TRUE           | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        1 | Peasant Peter                | A                | peasantpeter          |   0.8787879 | NA             | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        2 | Peasant Peter                | Z                | peasantpeter          |   0.8787879 | NA             | NA            |
|   5 | Bread Bakers Limited   | 23456 | germany | C          | breadbakers ltd     |        5 | The Bread Bakers Ltd         | C                | thebreadbakers ltd    |   0.8444444 | NA             | NA            |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        7 | Flower Power and Co.         | F                | flowerpower co        |   1.0000000 | TRUE           | NA            |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        6 | Flower Power Friends and Co. | D                | flowerpowerfriends co |   0.9333333 | NA             | NA            |
|   7 | Screwdriver Experts    | 45678 | germany | D          | screwdriverexperts  |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   8 | Screwdriver Expert     | 45678 | germany | Z          | screwdriverexpert   |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   9 | John Meier’s Groceries | 56789 | germany | E          | johnmeiersgroceries |        8 | John and Jacques Groceries   | E                | johnjacquesgroceries  |   0.8478947 | NA             | NA            |
|  10 | John Meier’s Groceries | 55555 | germany | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|  11 | John Meier’s Groceries | 55555 | norway  | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |

**Note**: even a match of 1 in the same zip code can in rare cases be a
False positive, compare e.g. company 4 (“Peasant Paul”) in the example
data.

### Check matching process

After having matched manually each companies, we can check for the
companies that were not matched in the loanbook. This can be used as a
‘double-check’ to see if the two data sets were correctly manually
matched. The demo-matched data set is an example of what the data set
should look like after being manually checked: the **accept\_match**
column is now changed to TRUE or NA, depending on whether a company
should be matched or not.

``` r
manually_matched <- demo_matched

knitr::kable(manually_matched)
```

|  id | company\_name          | zip   | country | misc\_info | company\_alias      | id\_tilt | company\_name\_tilt          | misc\_info\_tilt | company\_alias\_tilt  | string\_sim | suggest\_match | accept\_match |
|----:|:-----------------------|:------|:--------|:-----------|:--------------------|---------:|:-----------------------------|:-----------------|:----------------------|------------:|:---------------|:--------------|
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | TRUE          |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | NA            |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | TRUE          |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   3 | Peasant Peter          | 11234 | germany | Z          | peasantpeter        |        3 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | TRUE           | TRUE          |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        4 | Peasant Paul                 | B                | peasantpaul           |   1.0000000 | TRUE           | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        1 | Peasant Peter                | A                | peasantpeter          |   0.8787879 | NA             | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        2 | Peasant Peter                | Z                | peasantpeter          |   0.8787879 | NA             | NA            |
|   5 | Bread Bakers Limited   | 23456 | germany | C          | breadbakers ltd     |        5 | The Bread Bakers Ltd         | C                | thebreadbakers ltd    |   0.8444444 | NA             | NA            |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        7 | Flower Power and Co.         | F                | flowerpower co        |   1.0000000 | TRUE           | TRUE          |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        6 | Flower Power Friends and Co. | D                | flowerpowerfriends co |   0.9333333 | NA             | NA            |
|   7 | Screwdriver Experts    | 45678 | germany | D          | screwdriverexperts  |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   8 | Screwdriver Expert     | 45678 | germany | Z          | screwdriverexpert   |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   9 | John Meier’s Groceries | 56789 | germany | E          | johnmeiersgroceries |        8 | John and Jacques Groceries   | E                | johnjacquesgroceries  |   0.8478947 | NA             | NA            |
|  10 | John Meier’s Groceries | 55555 | germany | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|  11 | John Meier’s Groceries | 55555 | norway  | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |

### Report companies with no matches

We can then use the **report\_no\_matches** function and determine
companies in the loanbook for which no match was selected or found.

``` r
not_matched <- report_no_matches(loanbook, manually_matched)
#> Joining, by = c("id", "company_name", "zip", "country", "misc_info",
#> "company_alias")
#> Companies not matched in the loanbook by the tilt data set: Peasant Paul Bread
#> Bakers Limited Screwdriver Experts Screwdriver Expert John Meier's Groceries
#> John Meier's Groceries John Meier's Groceries ℹ Did you match these companies
#> manually correctly ?

knitr::kable(not_matched)
```

|  id | company\_name          |
|----:|:-----------------------|
|   4 | Peasant Paul           |
|   5 | Bread Bakers Limited   |
|   7 | Screwdriver Experts    |
|   8 | Screwdriver Expert     |
|   9 | John Meier’s Groceries |
|  10 | John Meier’s Groceries |
|  11 | John Meier’s Groceries |

### Report duplicate matches

To check some manual errors during the manual matching process, we can
use the **check\_duplicated\_relation** function. It checks if a company
from loanbook has been matched to &gt; 1 company from the tilt dataset
or reverse.

Here, the demo\_matched data set is hand-matched correctly: the column
**accept\_match** has been manually changed and verified.

``` r
manually_matched <- demo_matched

knitr::kable(manually_matched)
```

|  id | company\_name          | zip   | country | misc\_info | company\_alias      | id\_tilt | company\_name\_tilt          | misc\_info\_tilt | company\_alias\_tilt  | string\_sim | suggest\_match | accept\_match |
|----:|:-----------------------|:------|:--------|:-----------|:--------------------|---------:|:-----------------------------|:-----------------|:----------------------|------------:|:---------------|:--------------|
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | TRUE          |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | NA            |
|   1 | Peasant Peter          | 01234 | germany | A          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        1 | Peasant Peter                | A                | peasantpeter          |   1.0000000 | NA             | NA            |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        2 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | NA             | TRUE          |
|   2 | Peasant Peter          | 01234 | germany | Z          | peasantpeter        |        4 | Peasant Paul                 | B                | peasantpaul           |   0.8787879 | NA             | NA            |
|   3 | Peasant Peter          | 11234 | germany | Z          | peasantpeter        |        3 | Peasant Peter                | Z                | peasantpeter          |   1.0000000 | TRUE           | TRUE          |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        4 | Peasant Paul                 | B                | peasantpaul           |   1.0000000 | TRUE           | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        1 | Peasant Peter                | A                | peasantpeter          |   0.8787879 | NA             | NA            |
|   4 | Peasant Paul           | 01234 | germany | Z          | peasantpaul         |        2 | Peasant Peter                | Z                | peasantpeter          |   0.8787879 | NA             | NA            |
|   5 | Bread Bakers Limited   | 23456 | germany | C          | breadbakers ltd     |        5 | The Bread Bakers Ltd         | C                | thebreadbakers ltd    |   0.8444444 | NA             | NA            |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        7 | Flower Power and Co.         | F                | flowerpower co        |   1.0000000 | TRUE           | TRUE          |
|   6 | Flower Power & Company | 34567 | germany | Z          | flowerpower co      |        6 | Flower Power Friends and Co. | D                | flowerpowerfriends co |   0.9333333 | NA             | NA            |
|   7 | Screwdriver Experts    | 45678 | germany | D          | screwdriverexperts  |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   8 | Screwdriver Expert     | 45678 | germany | Z          | screwdriverexpert   |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|   9 | John Meier’s Groceries | 56789 | germany | E          | johnmeiersgroceries |        8 | John and Jacques Groceries   | E                | johnjacquesgroceries  |   0.8478947 | NA             | NA            |
|  10 | John Meier’s Groceries | 55555 | germany | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |
|  11 | John Meier’s Groceries | 55555 | norway  | Y          | johnmeiersgroceries |       NA | NA                           | NA               | NA                    |          NA | NA             | NA            |

The function does not throw an error and inform that no duplicates were
found.

``` r
check_duplicated_relation(manually_matched)
#> No duplicated matches found in the data.
```

Now let us insert duplicated matches for the company with the ids 1 and
2.

``` r
duplicate_in_loanbook <- manually_matched %>% 
  dplyr::mutate(accept_match = dplyr::if_else(id %in% c(1, 2), TRUE, accept_match))

knitr::kable(duplicate_in_loanbook %>% dplyr::filter(id %in% c(1, 2)))
```

|  id | company\_name | zip   | country | misc\_info | company\_alias | id\_tilt | company\_name\_tilt | misc\_info\_tilt | company\_alias\_tilt | string\_sim | suggest\_match | accept\_match |
|----:|:--------------|:------|:--------|:-----------|:---------------|---------:|:--------------------|:-----------------|:---------------------|------------:|:---------------|:--------------|
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        1 | Peasant Peter       | A                | peasantpeter         |   1.0000000 | NA             | TRUE          |
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        2 | Peasant Peter       | Z                | peasantpeter         |   1.0000000 | NA             | TRUE          |
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        4 | Peasant Paul        | B                | peasantpaul          |   0.8787879 | NA             | TRUE          |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        1 | Peasant Peter       | A                | peasantpeter         |   1.0000000 | NA             | TRUE          |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        2 | Peasant Peter       | Z                | peasantpeter         |   1.0000000 | NA             | TRUE          |
|   2 | Peasant Peter | 01234 | germany | Z          | peasantpeter   |        4 | Peasant Paul        | B                | peasantpaul          |   0.8787879 | NA             | TRUE          |

The function then abort and throws an error with the lines of the
duplicated rows.

``` r
# un-comment this line to have the error
# check_duplicated_relation(duplicate_in_loanbook)
```

Also, an error is thrown if we insert a duplicate match of a company
from the tilt db to the loanbook.

``` r
duplicate_tilt_id <- demo_matched %>% 
  dplyr::mutate(id_tilt = dplyr::if_else(accept_match == TRUE & id_tilt == 3, 1, id_tilt)) 

knitr::kable(duplicate_tilt_id %>% dplyr::filter(accept_match == TRUE & id_tilt == 1))
```

|  id | company\_name | zip   | country | misc\_info | company\_alias | id\_tilt | company\_name\_tilt | misc\_info\_tilt | company\_alias\_tilt | string\_sim | suggest\_match | accept\_match |
|----:|:--------------|:------|:--------|:-----------|:---------------|---------:|:--------------------|:-----------------|:---------------------|------------:|:---------------|:--------------|
|   1 | Peasant Peter | 01234 | germany | A          | peasantpeter   |        1 | Peasant Peter       | A                | peasantpeter         |           1 | NA             | TRUE          |
|   3 | Peasant Peter | 11234 | germany | Z          | peasantpeter   |        1 | Peasant Peter       | Z                | peasantpeter         |           1 | TRUE           | TRUE          |

``` r
# un-comment this line to have the error
# check_duplicated_relation(duplicate_tilt_id)
```
