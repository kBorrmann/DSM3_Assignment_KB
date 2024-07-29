# Assessment DP-SMB - NextImmune2 - Data Science Meetings (Common Data Science Tools) - Klara Borrmann
This repository branch contains the completed tasks and comments.

## Task 2
The solution can be found in Assignments --> Phython.

I got an error message when using expr.index: "'Range Index' object is not callable." That is why after some research with Stack overflow, I decided to do expr.set_index instead. With this result dropping the first column would delete one tested individuum. The code could have been expr.drop(expr.columns[0]). 

Two comments in case you want to use this notebook for other courses again.
In the following hint is a spelling mistake: "'.apply(convert_to_month)'" it should be '.apply(convert_to_months)'.
In "use the Test Number from md['Test number'] as new column names for the expr data" md['Test umber'] should already have been renamed to md['TestID'].

## Task 3
The app can be found in the folder Thermal Proteome Profiling Data. I also attached two images of how the app would look.
