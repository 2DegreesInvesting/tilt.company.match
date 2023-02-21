
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

- matching companies from banks\` loanbooks to tilt will face problems
  of inconsistent company names (typos, conventions…)

- it is expected that postcode will be available as relatively reliable
  additional information for most companies

- not all companies in loanbooks will be in tilt db (thus not have a
  match)

To match the companies provided in a loanbook to companies in the tilt
database we expect a loanbook dataframe and a tilt db dataframe that
hold at least the columns **company_name**, **postcode** and **country**
and a column **id** holding unique row identifiers. Further columns that
educate decisions made by humans in the matching process may be present.
For an example compare demo data below.

``` r
library(tilt.company.match)
#> Loading required package: stringdist
knitr::kable(head(demo_loanbook))
```

|  id | company_name           | postcode | country | misc_info |
|----:|:-----------------------|:---------|:--------|:----------|
|   1 | Peasant Peter          | 01234    | germany | A         |
|   2 | Peasant Peter          | 01234    | germany | Z         |
|   3 | Peasant Peter          | 11234    | germany | Z         |
|   4 | Peasant Paul           | 01234    | germany | Z         |
|   5 | Bread Bakers Limited   | 23456    | germany | C         |
|   6 | Flower Power & Company | 34567    | germany | Z         |

### Pre-matching functions to check the data

I order to run the matching process optimally, here are some useful
functions to check your data before the matching process.

#### Check crucial columns names

It is crucial to have the right columns’ names in your loanbook, exactly
like in our demo_loanbook. Here is a function to check if your loanbook
has the necessary names, which are declared under “crucial_names”.

``` r
loanbook <- demo_loanbook
crucial_names <- c("id", "company_name", "postcode", "country")
check_crucial_names(loanbook, crucial_names)
```

Now, let us rename the loanbook “country” column into “countries” and
“company_name” into “Company Name”. If you un-comment (remove the
hashtag) the line, it throws an error.

``` r
wrongly_named_loanbook <- loanbook %>%
  dplyr::rename(
    "countries" = "country",
    "Company Name" = "company_name"
  )

# un-comment this line to have the error
# check_crucial_names(wrongly_named_loanbook, crucial_names)
```

If you have an error in your loanbook, you can rename your loanbook
columns, using the dplyr::rename() function, and perform a sanity check
just after.

``` r
corrected_loanbook <- wrongly_named_loanbook %>%
  dplyr::rename(
    "country" = "countries",
    "company_name" = "Company Name"
  )

check_crucial_names(corrected_loanbook, crucial_names)
```

#### Report duplicates

The function **report_duplicates** shows whether there are duplicates on
some columns of interest. In this case, we strongly suggest duplicates
on the **company_name**, **postcode** and **country** columns
combination. We strongly encourage to use it on the loanbook data set.

``` r
loanbook <- demo_loanbook
columns <- c("company_name", "postcode", "country")

report_duplicates(loanbook, columns)
#> Found duplicate(s) on columns company_name, postcode, country of the data set.
#> ✖ Found for the company Peasant Peter, postcode: 01234, country: germany
#> ℹ Please check if these duplicates are intended and have an unique id.
```

Note: In our example we see, that while there are duplicate rows on
columns company_name, postcode, country they seem to do belong to
different companies so we do not need to fix this in our loanbook.

#### Report missing values

Missing values or NAs should ideally exist not in the loanbook. The
function **abort_if_incomplete()** checks how many NAs there are in each
columns of the data set and report them to the user.

Here, the loanbook data set does not have any NAs.

``` r
abort_if_incomplete(demo_loanbook, non_nullable_cols = c("id", "company_name"))
```

There are some columns (currently **id** and **company_name**) on which
we do not allow missings. In case there are missings on these columns
report_missings() will throw an error. You then have to removed affected
rows from your data. On other columns, e.g. **postcode** missings will
be reported for information purposes. However they do not require action
from user side.

``` r
# missings on a non-crucial column
missing_non_crucial <- demo_loanbook %>% 
  dplyr::mutate(postcode = dplyr::if_else(id == 1, NA_character_, .data$postcode))
missing_non_crucial %>% 
  abort_if_incomplete(non_nullable_cols = c("id", "company_name"))
# missings on a crucial column
missing_crucial <- demo_loanbook %>% 
  dplyr::mutate(company_name = dplyr::if_else(id == 1, NA_character_, .data$postcode))
missing_crucial %>% 
  abort_if_incomplete(non_nullable_cols = c("id", "company_name"))
#> Error in `abort_if_incomplete()`:
#> ! Non-nullable columns must not have `NA`s.
#> ✖ Columns to review: company_name
```

### Preprocessing

In a first step, the company_names are preprocessed to reduce noise and
increase consistency. To this end use a function called to_alias(). We
assign the result of the preprocessing to a new column
**company_alias**.

``` r
loanbook <- demo_loanbook %>%
  dplyr::mutate(company_alias = to_alias(company_name))

knitr::kable(head(loanbook))
```

|  id | company_name           | postcode | country | misc_info | company_alias   |
|----:|:-----------------------|:---------|:--------|:----------|:----------------|
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter    |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter    |
|   3 | Peasant Peter          | 11234    | germany | Z         | peasantpeter    |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul     |
|   5 | Bread Bakers Limited   | 23456    | germany | C         | breadbakers ltd |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co  |

``` r

tilt <- demo_tilt %>%
  dplyr::mutate(company_alias = to_alias(company_name))

knitr::kable(head(tilt))
```

|  id | company_name                 | postcode | country | misc_info | company_alias         |
|----:|:-----------------------------|:---------|:--------|:----------|:----------------------|
|   1 | Peasant Peter                | 01234    | germany | A         | peasantpeter          |
|   2 | Peasant Peter                | 01234    | germany | Z         | peasantpeter          |
|   3 | Peasant Peter                | 11234    | germany | Z         | peasantpeter          |
|   4 | Peasant Paul                 | 01234    | germany | B         | peasantpaul           |
|   5 | The Bread Bakers Ltd         | 23456    | germany | C         | thebreadbakers ltd    |
|   6 | Flower Power Friends and Co. | 34567    | germany | D         | flowerpowerfriends co |

### Deriving Candidates

To identify which entries from the tilt db match to the companies in the
loanbook, we identify in a first step all companies with a matching
country and postcode. This is based on the assumptions that postcodes
are correct and stable.

For cases for which no postcode, but country is available we match only
on country. For companies for which neither postcode nor country are
around we consider all companies potential candidates. We treat cases
that have postcode but not country the same way, it would possible
induce false positive to match via postcode over different countries.

``` r
loanbook_no_nas <- loanbook %>% 
  dplyr::filter(!is.na(postcode) & !is.na(country))

loanbook_na_postcode <- loanbook %>% 
  dplyr::filter(is.na(postcode) & !is.na(country))

loanbook_nas_country_postcode <- loanbook %>% 
  dplyr::filter(is.na(country))
```

``` r
loanbook_no_nas_with_candidates <- loanbook_no_nas %>%
  dplyr::left_join(tilt, by = c("country", "postcode"), suffix = c("", "_tilt"))
#> Warning in dplyr::left_join(., tilt, by = c("country", "postcode"), suffix = c("", : Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.

loanbook_na_postcode_with_candidates <- loanbook_na_postcode %>%
  dplyr::left_join(tilt, by = c("country"), suffix = c("", "_tilt"))
#> Warning in dplyr::left_join(., tilt, by = c("country"), suffix = c("", "_tilt")): Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.

loanbook_nas_country_postcode_with_candidates <- loanbook_nas_country_postcode %>%
  dplyr::mutate(postcode = "join_helper") %>% 
  dplyr::inner_join(tilt %>%
                      dplyr::mutate(postcode = "join_helper"), 
                    by = c("postcode"), suffix = c("", "_tilt")) %>% 
  dplyr::mutate(postcode = NA_character_)
#> Warning in dplyr::inner_join(., tilt %>% dplyr::mutate(postcode = "join_helper"), : Each row in `x` is expected to match at most 1 row in `y`.
#> ℹ Row 1 of `x` matches multiple rows.
#> ℹ If multiple matches are expected, set `multiple = "all"` to silence this
#>   warning.

loanbook_with_candidates <- dplyr::bind_rows(
  loanbook_no_nas_with_candidates, 
  loanbook_na_postcode_with_candidates,
  loanbook_nas_country_postcode_with_candidates)


knitr::kable(head(loanbook_with_candidates))
```

|  id | company_name  | postcode | country | misc_info | company_alias | id_tilt | company_name_tilt | misc_info_tilt | company_alias_tilt | postcode_tilt | country_tilt |
|----:|:--------------|:---------|:--------|:----------|:--------------|--------:|:------------------|:---------------|:-------------------|:--------------|:-------------|
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       1 | Peasant Peter     | A              | peasantpeter       | NA            | NA           |
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       2 | Peasant Peter     | Z              | peasantpeter       | NA            | NA           |
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       4 | Peasant Paul      | B              | peasantpaul        | NA            | NA           |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       1 | Peasant Peter     | A              | peasantpeter       | NA            | NA           |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       2 | Peasant Peter     | Z              | peasantpeter       | NA            | NA           |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       4 | Peasant Paul      | B              | peasantpaul        | NA            | NA           |

One can see that e.g. the company with the loanbook id 1 has 3 potential
matches in the tilt db that have the same postcode (tilt id 1, 2, 4).

Next, we are calculating the string similarity between the aliased
company name in the loanbook with the aliased company names in the tilt
db in the same postcode and ordering by descending proximity. A complete
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

|  id | company_name           | postcode | country | misc_info | company_alias       | id_tilt | company_name_tilt            | misc_info_tilt | company_alias_tilt    | postcode_tilt | country_tilt | string_sim |
|----:|:-----------------------|:---------|:--------|:----------|:--------------------|--------:|:-----------------------------|:---------------|:----------------------|:--------------|:-------------|-----------:|
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  1.0000000 |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  0.8787879 |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  1.0000000 |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  0.8787879 |
|   3 | Peasant Peter          | 11234    | germany | Z         | peasantpeter        |       3 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  1.0000000 |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  0.8787879 |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  0.8787879 |
|   5 | Bread Bakers Limited   | 23456    | germany | C         | breadbakers ltd     |       5 | The Bread Bakers Ltd         | C              | thebreadbakers ltd    | NA            | NA           |  0.8444444 |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       7 | Flower Power and Co.         | F              | flowerpower co        | NA            | NA           |  1.0000000 |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       6 | Flower Power Friends and Co. | D              | flowerpowerfriends co | NA            | NA           |  0.9333333 |
|   7 | Screwdriver Experts    | 45678    | germany | D         | screwdriverexperts  |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA |
|   8 | Screwdriver Expert     | 45678    | germany | Z         | screwdriverexpert   |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA |
|   9 | John Meier’s Groceries | 56789    | germany | E         | johnmeiersgroceries |       8 | John and Jacques Groceries   | E              | johnjacquesgroceries  | NA            | NA           |  0.8478947 |
|  10 | John Meier’s Groceries | 55555    | germany | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA |
|  11 | John Meier’s Groceries | 55555    | norway  | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA |
|  12 | Best Bakers            | 65656    | france  | F         | bestbakers          |      11 | Cranes and Friends           | F              | cranesfriends         | NA            | NA           |  0.5482906 |
|  13 | Concrete Incorporated  | NA       | france  | G         | concrete inc        |      12 | Concrete Inc                 | G              | concrete inc          | 12345         | NA           |  1.0000000 |
|  13 | Concrete Incorporated  | NA       | france  | G         | concrete inc        |      11 | Cranes and Friends           | F              | cranesfriends         | 65656         | NA           |  0.6508242 |
|  13 | Concrete Incorporated  | NA       | france  | G         | concrete inc        |      13 | Your web consultants         | H              | yourwebconsultants    | 12345         | NA           |  0.5383598 |
|  13 | Concrete Incorporated  | NA       | france  | G         | concrete inc        |      10 | John and Jacques Groceries   | E              | johnjacquesgroceries  | 98765         | NA           |  0.5222222 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |      13 | Your web consultants         | H              | yourwebconsultants    | NA            | france       |  0.8900463 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |      11 | Cranes and Friends           | F              | cranesfriends         | NA            | france       |  0.5634158 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |      12 | Concrete Inc                 | G              | concrete inc          | NA            | france       |  0.5545635 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | germany      |  0.5484307 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       1 | Peasant Peter                | A              | peasantpeter          | NA            | germany      |  0.5097222 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | germany      |  0.5097222 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       3 | Peasant Peter                | Z              | peasantpeter          | NA            | germany      |  0.5097222 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       8 | John and Jacques Groceries   | E              | johnjacquesgroceries  | NA            | germany      |  0.4875000 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       9 | John and Jacques Groceries   | E              | johnjacquesgroceries  | NA            | germany      |  0.4875000 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |      10 | John and Jacques Groceries   | E              | johnjacquesgroceries  | NA            | france       |  0.4875000 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       7 | Flower Power and Co.         | F              | flowerpower co        | NA            | germany      |  0.4565476 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       5 | The Bread Bakers Ltd         | C              | thebreadbakers ltd    | NA            | germany      |  0.4421296 |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |       6 | Flower Power Friends and Co. | D              | flowerpowerfriends co | NA            | germany      |  0.4236111 |

Based an empiric research we decided to remove match candidates with a
similarity under a certain threshold. This helps drastically reduce the
number of candidates, making the data easier to process for a human.

``` r
min_threshold <- 0.75

loanbook_with_candidates_and_dist_filtered <- loanbook_with_candidates_and_dist %>% 
  dplyr::filter(is.na(string_sim) | string_sim > min_threshold)
```

Note that, in very rare cases, we might loose matches this way, since
candidates that are removed here due to the lower threshold are no
longer included in the matching. We concluded that the improved ease of
use justifies those edgecases. Companies that have no more candidates
after filtering with the lower threshold are reported.

``` r
before_filter_id_and_company <- loanbook_with_candidates_and_dist %>% 
  dplyr::select(id, company_name) %>% 
  dplyr::distinct_all()

after_filter_id_and_company <- loanbook_with_candidates_and_dist_filtered %>% 
  dplyr::select(id, company_name) %>% 
  dplyr::distinct_all()

lost_companies <- before_filter_id_and_company %>% 
  dplyr::anti_join(after_filter_id_and_company)
#> Joining with `by = join_by(id, company_name)`

knitr::kable(lost_companies)
```

|  id | company_name |
|----:|:-------------|
|  12 | Best Bakers  |

## Selecting matches

In order to make the work of a human working on the matching as easy as
possible what can be automated should be automated. However correct
matching is essential for the project success so incorrect matches,
which cannot ultimately be ruled out when matching automatically are not
acceptable. As a consequence for now the following workflow is
suggested.

A human coder will have to inspect the data. It is advisable do to so in
a spreadsheet application. A row is selected as match by setting column
**accept_match** to TRUE. To support this the column **suggest_match**
is provided.

The **suggest_match** column is set to TRUE if:

- The match is above a determined threshold.
- It is the highest match of all matches.
- There is only 1 highest match per **company_name** x **id**
  combination to avoid duplicates.
- country and postcode are available for the company in the loanbook

``` r
highest_matches_per_company <- loanbook_with_candidates_and_dist_filtered %>%
  dplyr::group_by(id) %>%
  dplyr::filter(string_sim == max(string_sim))

threshold <- 0.9 # Threshold decided upon extensive experience with r2dii.match function and processes

highest_matches_per_company_above_thresh <- highest_matches_per_company %>%
  dplyr::filter(string_sim > threshold) %>% 
  dplyr::filter(!is.na(postcode) & !is.na(country))

highest_matches_per_company_above_thresh_wo_duplicates <- highest_matches_per_company_above_thresh %>%
  dplyr::mutate(duplicates = any(duplicated(company_name, postcode))) %>%
  dplyr::filter(duplicates == FALSE) %>%
  dplyr::select(id, id_tilt) %>%
  dplyr::mutate(suggest_match = TRUE)

loanbook_with_candidates_and_dist_and_suggestion <- loanbook_with_candidates_and_dist_filtered %>%
  dplyr::left_join(highest_matches_per_company_above_thresh_wo_duplicates, by = c("id", "id_tilt")) %>%
  dplyr::mutate(accept_match = NA)

knitr::kable(loanbook_with_candidates_and_dist_and_suggestion)
```

|  id | company_name           | postcode | country | misc_info | company_alias       | id_tilt | company_name_tilt            | misc_info_tilt | company_alias_tilt    | postcode_tilt | country_tilt | string_sim | suggest_match | accept_match |
|----:|:-----------------------|:---------|:--------|:----------|:--------------------|--------:|:-----------------------------|:---------------|:----------------------|:--------------|:-------------|-----------:|:--------------|:-------------|
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  1.0000000 | NA            | NA           |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 | NA            | NA           |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  0.8787879 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  1.0000000 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  0.8787879 | NA            | NA           |
|   3 | Peasant Peter          | 11234    | germany | Z         | peasantpeter        |       3 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  1.0000000 | TRUE          | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       4 | Peasant Paul                 | B              | peasantpaul           | NA            | NA           |  1.0000000 | TRUE          | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       1 | Peasant Peter                | A              | peasantpeter          | NA            | NA           |  0.8787879 | NA            | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       2 | Peasant Peter                | Z              | peasantpeter          | NA            | NA           |  0.8787879 | NA            | NA           |
|   5 | Bread Bakers Limited   | 23456    | germany | C         | breadbakers ltd     |       5 | The Bread Bakers Ltd         | C              | thebreadbakers ltd    | NA            | NA           |  0.8444444 | NA            | NA           |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       7 | Flower Power and Co.         | F              | flowerpower co        | NA            | NA           |  1.0000000 | TRUE          | NA           |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       6 | Flower Power Friends and Co. | D              | flowerpowerfriends co | NA            | NA           |  0.9333333 | NA            | NA           |
|   7 | Screwdriver Experts    | 45678    | germany | D         | screwdriverexperts  |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA | NA            | NA           |
|   8 | Screwdriver Expert     | 45678    | germany | Z         | screwdriverexpert   |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA | NA            | NA           |
|   9 | John Meier’s Groceries | 56789    | germany | E         | johnmeiersgroceries |       8 | John and Jacques Groceries   | E              | johnjacquesgroceries  | NA            | NA           |  0.8478947 | NA            | NA           |
|  10 | John Meier’s Groceries | 55555    | germany | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA | NA            | NA           |
|  11 | John Meier’s Groceries | 55555    | norway  | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    | NA            | NA           |         NA | NA            | NA           |
|  13 | Concrete Incorporated  | NA       | france  | G         | concrete inc        |      12 | Concrete Inc                 | G              | concrete inc          | 12345         | NA           |  1.0000000 | NA            | NA           |
|  14 | Ur web consultants     | NA       | NA      | H         | urwebconsultants    |      13 | Your web consultants         | H              | yourwebconsultants    | NA            | france       |  0.8900463 | NA            | NA           |

**Notes**:

- Even a match of 1 in the same postcode can in rare cases be a False
  positive, compare e.g. company 4 (“Peasant Paul”) in the example data.
- We do not want to automatically approve unique matches because there
  may be few cases where multiple companies in the same ZIP code have
  the same name. In these cases, additional information (for example,
  the sector, street name, or main activity etc.) can help to make a
  final decision.

### Check matching process

After having matched manually each companies, we can check for the
companies that were not matched in the loanbook. This can be used as a
‘double-check’ to see if the two data sets were correctly manually
matched. The demo-matched data set is an example of what the data set
should look like after being manually checked: the **accept_match**
column is now changed to TRUE or NA, depending on whether a company
should be matched or not.

``` r
manually_matched <- demo_matched

knitr::kable(manually_matched)
```

|  id | company_name           | postcode | country | misc_info | company_alias       | id_tilt | company_name_tilt            | misc_info_tilt | company_alias_tilt    | string_sim | suggest_match | accept_match |
|----:|:-----------------------|:---------|:--------|:----------|:--------------------|--------:|:-----------------------------|:---------------|:----------------------|-----------:|:--------------|:-------------|
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          |  1.0000000 | NA            | TRUE         |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | NA            | NA           |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           |  0.8787879 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          |  1.0000000 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | NA            | TRUE         |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           |  0.8787879 | NA            | NA           |
|   3 | Peasant Peter          | 11234    | germany | Z         | peasantpeter        |       3 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | TRUE          | TRUE         |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       4 | Peasant Paul                 | B              | peasantpaul           |  1.0000000 | TRUE          | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       1 | Peasant Peter                | A              | peasantpeter          |  0.8787879 | NA            | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       2 | Peasant Peter                | Z              | peasantpeter          |  0.8787879 | NA            | NA           |
|   5 | Bread Bakers Limited   | 23456    | germany | C         | breadbakers ltd     |       5 | The Bread Bakers Ltd         | C              | thebreadbakers ltd    |  0.8444444 | NA            | NA           |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       7 | Flower Power and Co.         | F              | flowerpower co        |  1.0000000 | TRUE          | TRUE         |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       6 | Flower Power Friends and Co. | D              | flowerpowerfriends co |  0.9333333 | NA            | NA           |
|   7 | Screwdriver Experts    | 45678    | germany | D         | screwdriverexperts  |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|   8 | Screwdriver Expert     | 45678    | germany | Z         | screwdriverexpert   |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|   9 | John Meier’s Groceries | 56789    | germany | E         | johnmeiersgroceries |       8 | John and Jacques Groceries   | E              | johnjacquesgroceries  |  0.8478947 | NA            | NA           |
|  10 | John Meier’s Groceries | 55555    | germany | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|  11 | John Meier’s Groceries | 55555    | norway  | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |

### Report companies with no matches

We can then use the **report_no_matches** function and determine
companies in the loanbook for which no match was selected or found.

``` r
not_matched <- report_no_matches(loanbook, manually_matched)
#> Joining with `by = join_by(id, company_name, postcode, country, misc_info,
#> company_alias)`
#> Companies not matched in the loanbook by the tilt data set: Peasant Paul Bread
#> Bakers Limited Screwdriver Experts Screwdriver Expert John Meier's Groceries
#> John Meier's Groceries John Meier's Groceries Best Bakers Concrete Incorporated
#> Ur web consultants ℹ Did you match these companies manually correctly ?

knitr::kable(not_matched)
```

| company_name           |  id |
|:-----------------------|----:|
| Peasant Paul           |   4 |
| Bread Bakers Limited   |   5 |
| Screwdriver Experts    |   7 |
| Screwdriver Expert     |   8 |
| John Meier’s Groceries |   9 |
| John Meier’s Groceries |  10 |
| John Meier’s Groceries |  11 |
| Best Bakers            |  12 |
| Concrete Incorporated  |  13 |
| Ur web consultants     |  14 |

### Report duplicate matches

To check some manual errors during the manual matching process, we can
use the **check_duplicated_relation** function. It checks if a company
from loanbook has been matched to \> 1 company from the tilt dataset or
reverse.

Here, the demo_matched data set is hand-matched correctly: the column
**accept_match** has been manually changed and verified.

``` r
manually_matched <- demo_matched

knitr::kable(manually_matched)
```

|  id | company_name           | postcode | country | misc_info | company_alias       | id_tilt | company_name_tilt            | misc_info_tilt | company_alias_tilt    | string_sim | suggest_match | accept_match |
|----:|:-----------------------|:---------|:--------|:----------|:--------------------|--------:|:-----------------------------|:---------------|:----------------------|-----------:|:--------------|:-------------|
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          |  1.0000000 | NA            | TRUE         |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | NA            | NA           |
|   1 | Peasant Peter          | 01234    | germany | A         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           |  0.8787879 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       1 | Peasant Peter                | A              | peasantpeter          |  1.0000000 | NA            | NA           |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       2 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | NA            | TRUE         |
|   2 | Peasant Peter          | 01234    | germany | Z         | peasantpeter        |       4 | Peasant Paul                 | B              | peasantpaul           |  0.8787879 | NA            | NA           |
|   3 | Peasant Peter          | 11234    | germany | Z         | peasantpeter        |       3 | Peasant Peter                | Z              | peasantpeter          |  1.0000000 | TRUE          | TRUE         |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       4 | Peasant Paul                 | B              | peasantpaul           |  1.0000000 | TRUE          | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       1 | Peasant Peter                | A              | peasantpeter          |  0.8787879 | NA            | NA           |
|   4 | Peasant Paul           | 01234    | germany | Z         | peasantpaul         |       2 | Peasant Peter                | Z              | peasantpeter          |  0.8787879 | NA            | NA           |
|   5 | Bread Bakers Limited   | 23456    | germany | C         | breadbakers ltd     |       5 | The Bread Bakers Ltd         | C              | thebreadbakers ltd    |  0.8444444 | NA            | NA           |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       7 | Flower Power and Co.         | F              | flowerpower co        |  1.0000000 | TRUE          | TRUE         |
|   6 | Flower Power & Company | 34567    | germany | Z         | flowerpower co      |       6 | Flower Power Friends and Co. | D              | flowerpowerfriends co |  0.9333333 | NA            | NA           |
|   7 | Screwdriver Experts    | 45678    | germany | D         | screwdriverexperts  |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|   8 | Screwdriver Expert     | 45678    | germany | Z         | screwdriverexpert   |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|   9 | John Meier’s Groceries | 56789    | germany | E         | johnmeiersgroceries |       8 | John and Jacques Groceries   | E              | johnjacquesgroceries  |  0.8478947 | NA            | NA           |
|  10 | John Meier’s Groceries | 55555    | germany | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |
|  11 | John Meier’s Groceries | 55555    | norway  | Y         | johnmeiersgroceries |      NA | NA                           | NA             | NA                    |         NA | NA            | NA           |

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

|  id | company_name  | postcode | country | misc_info | company_alias | id_tilt | company_name_tilt | misc_info_tilt | company_alias_tilt | string_sim | suggest_match | accept_match |
|----:|:--------------|:---------|:--------|:----------|:--------------|--------:|:------------------|:---------------|:-------------------|-----------:|:--------------|:-------------|
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       1 | Peasant Peter     | A              | peasantpeter       |  1.0000000 | NA            | TRUE         |
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       2 | Peasant Peter     | Z              | peasantpeter       |  1.0000000 | NA            | TRUE         |
|   1 | Peasant Peter | 01234    | germany | A         | peasantpeter  |       4 | Peasant Paul      | B              | peasantpaul        |  0.8787879 | NA            | TRUE         |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       1 | Peasant Peter     | A              | peasantpeter       |  1.0000000 | NA            | TRUE         |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       2 | Peasant Peter     | Z              | peasantpeter       |  1.0000000 | NA            | TRUE         |
|   2 | Peasant Peter | 01234    | germany | Z         | peasantpeter  |       4 | Peasant Paul      | B              | peasantpaul        |  0.8787879 | NA            | TRUE         |

The function then abort and throws an error with the lines of the
duplicated rows.

``` r
# un-comment this line to have the error
# check_duplicated_relation(duplicate_in_loanbook)
```

Also, an error is thrown if we insert a duplicate match of a company
from the tilt db to the loanbook.

``` r
duplicate_tilt_id_row <- demo_matched %>%
  dplyr::filter(id_tilt == 3) %>%
  dplyr::mutate(id = 12)
duplicate_tilt_id <- dplyr::bind_rows(demo_matched, duplicate_tilt_id_row)

knitr::kable(duplicate_tilt_id %>% dplyr::filter(accept_match == TRUE & id_tilt == 3))
```

|  id | company_name  | postcode | country | misc_info | company_alias | id_tilt | company_name_tilt | misc_info_tilt | company_alias_tilt | string_sim | suggest_match | accept_match |
|----:|:--------------|:---------|:--------|:----------|:--------------|--------:|:------------------|:---------------|:-------------------|-----------:|:--------------|:-------------|
|   3 | Peasant Peter | 11234    | germany | Z         | peasantpeter  |       3 | Peasant Peter     | Z              | peasantpeter       |          1 | TRUE          | TRUE         |
|  12 | Peasant Peter | 11234    | germany | Z         | peasantpeter  |       3 | Peasant Peter     | Z              | peasantpeter       |          1 | TRUE          | TRUE         |

``` r
# un-comment this line to have the error
# check_duplicated_relation(duplicate_tilt_id)
```
