# MIT_6.828
First I learned the methods to push new files to GitHub. Several ideas are important to the pushing process.

### Basic Methods:
1. Open Github Desktop and clone the program you want to make changes to
2. Open the terminal and access the folder
3. Run the following commands for regular push
  ```
  git init (Create .git file to the folder which is invisible)
  git add . (Add all files and folders under the directory for commit)
  git commit -m "ANY COMMENT YOU WANT TO PUT"
  git push origin master
  ```

### Problem solving:
1. If there is some invisible .git folder under the files you want to uploaded other than the one you created by "git init", problems may happen. In order to solve this, you can first delete the hidden ".git" files and then "git add." again for re-upload.
2. "Remote origin already exists" error: Run "git remote remove origin"
3. Method get rid of ".DS_store" file: Run "git rm --cached .DS_Store"
