# doitim-2do

This tool faciliates migration from doit.im to 2do app.

Doit.im does not have export functionality but there REST API is decent.
2Do has API for task insertion https://www.2doapp.com/kb/article/url-schemes.html

I created these scripts for own migration, make sure to understand limitations. This tool might be not good enough for your data.

# limitations

Scripts were used for ad-hoc one time migration, so they intentionally do not support many doit.im features I don't personally use. I ran in on Mac, I did not have much special characters in tasks, I limited migration to the following

* Projects. Follow the script on screen instructions. Only project title is considered, not notes.
* Tasks. All tasks in today tomorrow next scheduled waiting inbox someday. I don't have inactive projects and I don't know if the script catch those tasks. Archived and deleted tasks are not transferred. I don't respect task time, only start date. I don't consider due date, estimate, etc. The script also grabs tasks' notes.
* Recurrent tasks are all set up monthly. 2doapp has very limited API for recurrent tasks, manual clean-up will be required
* Contexts are converted to tags.
* Tags, goals, google calendar integration - not supported

Overall, follow the script code to make sense of what's being migrated and how.

# How to use

* You need `jq`, `curl` and obviously 2doapp installed.
* In a browser, navigate to doit.im, login, and extract `Cookie` key-value pair `autologin=<some-guid>` (example: `autologin=835a6dea-babb-4201-863e-dcb10abc6715`). Put `autologin=<some-guid>` into .env file
* Launch ./main.sh and follow instructions.

# Contributions

Contributions are welcome
