# 🎉 steve - Control Mac Apps Easily

<img src="steve-logo.webp" alt="steve" width="400">

## 🛠️ Download & Install

[![Download the latest release](https://img.shields.io/badge/Download%20Latest%20Release-blue)](https://github.com/mikker/steve/releases/latest)

To get started with steve, download it from the [Releases page](https://github.com/mikker/steve/releases/latest). This page contains the latest version of the software.

You can also install steve using Homebrew. Homebrew is a package manager for macOS that makes it easy to install software. If you prefer this method, open your Terminal and copy the following commands:

```
brew tap mikker/tap
brew install steve
```

Once you have downloaded and installed steve, you are ready to use it.

## 🚀 Getting Started

steve is a command-line interface (CLI) application designed to help you control other Mac applications. This tool utilizes the Accessibility API to automate tasks, making it useful for testing and controlling apps with AI agents.

### 📋 System Requirements

To run steve, ensure your Mac meets the following requirements:

- macOS version: 10.12 or later
- Command Line Tools for Xcode (can be installed via Terminal using `xcode-select --install`)

### 🖥️ Basic Usage

When you run steve, it outputs structured text to the command line by default. If you want to take screenshots, steve can output a PNG file as well. Here's a quick overview of the basic commands:

- **Output Formats**: By default, steve outputs plain text. To get JSON output, use the `--format json` option. You can also use the shorthand `-j`.

- **Error Handling**: If something goes wrong, errors will show up in the command line. These errors return a non-zero exit code.

Here are some example outputs you may encounter:

#### Text Output:

```
- Extensions
  frame: x=837 y=157 w=885 h=814
```

#### JSON Output:

```
{"ok":true,"data":...}
{"ok":false,"error":"message"}
```

## 🎮 Application Control

With steve, you can perform simple operations on your applications. Here are some of the main commands you can use:

- **List All Applications**: 
  ```
  steve apps
  ```

- **Focus on an Application**: 
  ```
  steve focus "AppName"
  ```

- **Focus Using PID (Process ID)**: 
  ```
  steve focus --pid 1234
  ```

- **Focus Using Bundle Identifier**: 
  ```
  steve focus --bundle "com.example.app"
  ```

- **Launch an Application**: 
  ```
  steve launch "com.example.app" --wait
  ```

These commands allow you to easily manage open applications on your Mac.

## 🔍 Features

steve provides a variety of features to enhance your experience:

- **Control Multiple Applications**: You can control any app that supports macOS Accessibility API.
  
- **Automation**: Use steve to automate repetitive tasks across your applications, saving you time and effort.

- **Flexible Outputs**: Choose between text and JSON formats to get the information you need in a way that suits your workflow.

- **Snapshot Capability**: Take screenshots of application windows directly through the CLI.

## 📝 Additional Resources

If you would like to learn more about steve and explore advanced features, check out the following resources:

- [Documentation](https://github.com/mikker/steve/wiki)
- [Community Support](https://github.com/mikker/steve/discussions)

### 🤝 Getting Help

If you encounter any problems or have questions, please reach out to the community through the GitHub Discussions section. You can also check the issues page for common problems and solutions.

Always make sure you have the latest version of steve to benefit from new features and fixes. You can download updates from the Releases page.

## ⚙️ Conclusion

steve is designed for simplicity and effectiveness. With easy installation and a straightforward command set, you can quickly start controlling your Mac applications. Whether for automation or testing, steve offers the tools you need to enhance your productivity. Follow the steps above to get started.