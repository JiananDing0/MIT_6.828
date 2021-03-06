# MIT_6.828
### Introduction
This is my first time taking such a hard course online. And it is also my first time to do github posting. So I will try my best. In this course, I will mainly focus on labs. But I will complete some homeworks that seems interesting.  

### GitHub Uploading
First I learned the methods to push new files to GitHub. Several ideas are important to the pushing process.

#### Basic Methods:
1. Open Github Desktop and clone the program you want to make changes to
2. Open the terminal and access the folder
3. Run the following commands for regular push
  ```
  git init (Create .git file to the folder which is invisible)
  git add . (Add all files and folders under the directory for commit)
  git commit -m "ANY COMMENT YOU WANT TO PUT"
  git push origin master
  ```

#### Problem solving:
1. If there is some invisible .git folder under the files you want to uploaded other than the one you created by "git init", problems may happen. In order to solve this, you can first delete the hidden ".git" files and then "git add." again for re-upload.
2. "Remote origin already exists" error: Run "git remote remove origin"
3. Method get rid of ".DS_store" file: Run "git rm --cached .DS_Store"
4. "Unrelated files" error: Run "git pull origin master --allow-unrelated-histories"

### Environment Settings
MacOS use homebrew as a package manager. As a result, I tried to run the following commands to set up a compilable environment on my Mac.
```
brew install qemu
brew tap liudangyi/i386-jos-elf-gcc
brew install i386-jos-elf-gcc i386-jos-elf-gdb
```
However, it shows that the third command requires we have already installed gdb on our Mac, otherwise, the "make gdb" step will not be compiled. So we need to run the follwing command first:
```
brew install gdb
```
And you can switch between different gdb by using:
```
brew link gdb
brew unlink i386-jos-elf-gdb
```
and 
```
brew unlink gdb
brew link i386-jos-elf-gdb
```
**NOTICE: you may need to run those commands to switch to i386-jos-elf-gdb everytime you swtich to a new lab**

### Problems with auto-grading the lab
The autograder sometimes does not work at all. In order to determine whether it is your own problem or auto-grader's fault, you may check the ```GradeProb.md``` for each lab seperately. If there is no such file exist for that lab, that means the grader has no problem.
