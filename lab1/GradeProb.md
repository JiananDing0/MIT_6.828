## Grading Problems
In the process of finishing my lab, I have found that no matter how I modify my lab code, the auto-grader of lab 1 never give me full mark. For example, when my lab output looks like:
```
6828 decimal is 15254 octal!
entering test_backtrace 5
entering test_backtrace 4
entering test_backtrace 3
entering test_backtrace 2
entering test_backtrace 1
....
```
The auto-grader still give me 0 for problem 1 because of 
```
MISSING '6828 decimal is 15254 octal!'
```
It is obvious that there might be some problem with the grading of lab 1. So I went through the autograder code located at ```lab/gradelib.py``` and ```lab/grade-lab1```

### Problem with grading question 1: matching problem:
Failing of the first test is because of the function used by testing the correctness of our output, the ```match``` function. It is implemented in ```lab/gradelib.py``` and called in ```lab/grade-lab1```. When we look into class ```Runner``` where the implementation of function ```match``` located in, we can easily figure out the logic of this function:
1. Divide all output from the booting process by line.
2. Store the lines of outputs into a list
3. Go through the list and compare whether there exist a line that matches the target string
  
The method seems to be reasonable. However, when we print out the strings that are actually stored into this list, here are the results:
```
['***', 
"*** Now run 'make gdb'.", 
'***', 
 ... 
'Booting from Hard Disk..6828 decimal is 15254 octal!', 
'entering test_backtrace 5', 
'entering test_backtrace 4', 
'entering test_backtrace 3',
 ...]
```
So the problem is obvious here. The autograder cannot determing our code because there is actually no matching. The line expected to be matched is now ```'Booting from Hard Disk..6828 decimal is 15254 octal!'```, which does not match at all. The solution to this problem is simple, we just add ```\n``` at the front of the string printed at line 36 of ```lab/kern/init.c```. This modification has been updated to my code in ```lab``` part.

#### The rest graders has no problem.
