## starting git
## clone from remote source
git clone https://github.com/ScaryDBA/HamshackOctopus.git

## initialize a local source
md .\GitIntroduction
cd .\GitIntroduction
git init

## working day to day
## get all the changes
git pull


## validate where we are
git status


## add a modified file 
git add gitintro.sql


## commit
git commit -am 'Demoing commit for presentation'

## push
git push

## branch
git branch 'NewBranch'