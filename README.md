# Project Creator

v0.0.1

This tiny script creartes project folder with structure shown below, install basic template and initializes git repository. It also can creates repository on GitHub and pushes the project to it.

Folder structure:

```md
  PROJECT NAME
  ├── project-assets
  └── project-name (git/gh repo)
       ├── README.md (only in gh repo)
       └── LICENSE (only in gh repo)
```

Current templates:

```md
  Empty JS Project
  Vite
  Next.js
  Create React App
```

## Prerequisites

To make sure that script works properly, you need to have [GitHub](https://github.com) account (if you want to have GH repo configured) and the following programs installed and configured correctly:

- git
- GitHub CLI (if you want to have GH repo configured)
- npm 

## Usage

First download script from github. Then you need to change the permissions of the script to make it executable. You can do this with the following command:

```bash
  chmod +x ./run.sh
```

or

```bash
  chmod +755 ./run.sh
```

If you don't want to write GitHub username every single time than modify this (3rd line):

```bash
  GH_USERNAME=""
```

so it looks like this:

```bash
  GH_USERNAME="your_username"
```

Then you can run the script with the following command:

```bash
  ./run.sh
```
