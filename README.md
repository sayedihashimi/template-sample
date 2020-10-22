# Template sample

This repo contains a couple samples showing how you can create a .net core template that can be used either by the
dotnet command line (`dotnet new`) or Visual Studio & Visual Studio for Mac. For more info see [.NET CLI Templates in Visual Studio
](https://devblogs.microsoft.com/dotnet/net-cli-templates-in-visual-studio/).

The samples are in the `src/content` folder.

Add an issue here, or reach out to [@SayedIHashimi](https://twitter.com/sayedihashimi) on twitter with any questions.

To discover templates that have already been created go to https://dotnetnew.azurewebsites.net/.

## Getting started creating templates

To get started creating templates, take a look at the following resources.
 - [How to create your own templates for dotnet new
](https://devblogs.microsoft.com/dotnet/how-to-create-your-own-templates-for-dotnet-new/)
 - [Custom templates for dotnet new
](https://docs.microsoft.com/en-us/dotnet/core/tools/custom-templates)

## How to enable cli templates in Visual Studio and Visual Studio for Mac

The feature to show templates that are installed using the command-line interface (cli) is a preview feature. This feature is disabled by default.

To enable this feature in ***Visual Studio***:

First open the Options dialog, go to `Tools > Options`. In the dialog go to `Environment > Preview Features` and then on the right-hand side and select the
preview feature named *Show all .NET Core templates in the New project dialog*. For more info see [.NET CLI Templates in Visual Studio
](https://devblogs.microsoft.com/dotnet/net-cli-templates-in-visual-studio/).

![Visual Studio - Tool > Options > Environment > Preview features](media/vs-preview-features.png)

To enable this feature inn ***Visual Studio for Mac***:

![Visual Studio - Tool > Options > Environment > Preview features](media/vsmac-preview-features.png)

First open the Preferences dialog, go to `Visual Studio (menu) > Preferences...`. In the list on the
left hand side, select `Other > Preview Features` and select the
preview feature named *Show all .NET Core templates in the New project dialog*.

## Visual Studio support

Starting in previews of 16.8 of Visual Studio we have a feature that can be enabled to show the templates
which have been installed with `dotnet new`. For more info on that take a look at the blog post [.NET CLI Templates in Visual Studio
](https://devblogs.microsoft.com/dotnet/net-cli-templates-in-visual-studio/).

There are some things that you'll want to make sure you have defined to ensure a good experience for
Visual Studio users.

### Use the schema for completions and validation

You should add the `$schema` property to your `template.json` file. Both Visual Studio and Visual Studio Code
will provide completions and validation based on the schema. Other editors have similar support as well.

```json
{
"$schema": "http://json.schemastore.org/template",
}
```

### `sourceName`

In the `template.json` file you should have a `sourceName` property declared. The `sourceName` property is special, and should always be declared. When a project is created, either through the command line or Visual Studio, the project will be given a name. For example, when creating a project with `dotnet new` you can pass in the `-n|--name` parameter. In Visual Studio during New Project the user will be prompted to provide a project name.
The value provided by the user for project name will replace the string declared in `sourceName`. This is typically
used to replace the `namespace` declaration in generated files.

```json
{
  "sourceName": "MyCommand",
}
```

For a full example of `sourceName` see [src/Content/MyCommand/.template.config/template.json](template.json)

### `defaultName`

When a project is created in Visual Studio, the screen that the user provides the project name will always be
pre-populated. If `defaultName` is declared in the `template.json`, that value will be used as the default name
for the project. Otherwise `Project1` is always used.
When users create projects from the command line with `dotnet new` if the `-n|--name` parameter is not passed in, the `defaultName` value will be used.

```json
{
  "defaultName": "MyCommandTool",
}
```

For a full example of `sourceName` see [src/Content/MyCommand/.template.config/template.json](template.json)

### `classifications`

In Visual Studio when creating a new project there is an `All Project Types` dropdown that can be used to filter
the list of templates shown. You should declare the relevant values from that dropdown in the `classifications`
property of the `template.json`. Here are some of the values that you can use.

 - Cloud
 - Console
 - Desktop
 - Games
 - IoT
 - Library
 - Mobile
 - Service
 - Web

Here is an example of the declaration.

```json
{
  "classifications": ["Console"],
}
```

Note: in the current preview the Visual Studio New Project Dialog will add all classifications from installed 
templates into the `All Project Types` dropdown. That behavior is likely to change, custom classifications
will not be listed. You should select the values that you see in Visual Studio (without any additional tempaltes installed) so that the user can filter.

### Language and type

In the `template.json` you should define the `language` and `type` for the template in the `tags` property. For
example

```json
"tags": {
  "language": "C#",
  "type":"project"
},
```

***If the `type` property is not declared, the template will not be shown in the Visual Studio New Project Dialog***

### Framework

In the `template.json` file you should indicate what target framework, or frameworks, the template supports.
To do that you'll update the `symbols` section to include a `Framework` property. Below is an example of what
should be included for a template that targets .NET Core 3.1.

```json
"symbols": {
  "Framework": {
    "type": "parameter",
    "description": "The target framework for the project.",
    "datatype": "choice",
    "choices": [
    {
        "choice": "netcoreapp3.1",
        "description": "Target netcoreapp3.1"
    }
    ],
    "replaces": "netcoreapp3.1",
    "defaultValue": "netcoreapp3.1"
  }
}
```

If your template supports multiple frameworks, add additional values to the `choices` array.

*Note: due to a bug, if your template contains parameters that you want to appear in Visual Studio, you'll need to specify the framework symbol.*

### Generating ports for web projects

If your template consists of a web project, it's likely that you'll want to generate new port numbers to be used
when the template is used. This is a bit complex to do correctly, but we will explain the different parts.
When defining the support, for each different port number we want the following to create a command line parameter
that can be used to explicitly set the port number. If the port number is not passed in by the user, then we want
to generate a port number automatically.

To achieve this, we will need to create three new symbols in the `template.json` file. We will create the following
symbols.

 - Parameter that the user can pass in
 - A generated port number
 - Symbol to coalesce the user parameter and the generated port

Here is a sample, where we specify the range that we want the port number to be in.

```json
"HttpsPort": {
  "type": "parameter",
  "datatype": "integer",
  "description": "Port number to use for the HTTPS endpoint in launchSettings.json."
},
"HttpsPortGenerated": {
  "type": "generated",
  "generator": "port",
  "parameters": {
  "low": 44300,
  "high": 44399
  }
},
"HttpsPortReplacer": {
  "type": "generated",
  "generator": "coalesce",
  "parameters": {
  "sourceVariableName": "HttpsPort",
  "fallbackVariableName": "HttpsPortGenerated"
  },
  "replaces": "44345"
}
```

`HttpsPort` is the user facing parameter that can be passed in when calling `dotnet new`.

`HttpsPortGenerated` is the generated port number. In this example we specified a `low` and a `high` value. The
generated port number will be between those. These parameters are optional.

`HttpsPortReplacer` is the symbol that will decide between `HttpsPort` and `HttpsPortGenerated`. If a value is provided via the command line (`HttpsPort`) it will be given preference. Take note of `44345` in this symbol. This
is the port number that the source files use. Where ever this string is found in the template content, it will
be replaced with the new port number.

For a full example of `sourceName` see [src/Content/MyWebApp/.template.config/template.json](template.json)

### Add an `ide.host.json` file

In order to get the best support in Visual Studio, you'll want to add an `ide.host.json` file. This file should 
be in the `.template.config` folder next to the `template.json` file. You'll need to create this file in order to
show an icon for the template, to display parameters, to customize the text, and other features.

The schema that you should use when creating this file is shown below.

```json
{
  "$schema": "http://json.schemastore.org/vs-2017.3.host"
}
```

### How to add an icon to be shown in Visual Studio

To add an icon, you will need to declare that in the `ide.host.json` file.
The icon file should be in, or under, the `.template.config` folder. In the `ide.host.json` file declare the icon property as shown.

```json
{
  "icon": "icon.png"
}
```

If the icon file is in a sub-folder, provide a relative path in the `icon` declaration.

In the image below the icon for the sample console template is shown.

![New Project Dialog - Custom template with icon](media/vs-npd-custom-template.png)

### How to make a parameter visible in Visual Studio

In `template.json` you can declare any number of parameters. Those parameters will not by default show up in
Visual Studio. You need to specify which ones should show up in Visual Studio with an `ide.host.json` file.
The `MyCommand` sample template in this repo has three parameters defined.

 - Framework
 - AuthorName
 - Description

The `Framework` parameter defines the set of choices of target framework that the template supports. This parameter
should always be defined for .NET Core templates. This parameter is special, and doesn't need to be declared in the
`ide.host.json` file to be shown in Visual Studio. If this parameter is defined, the Target Framework dropdown in the New Project Dialog will automatically be shown.

In order to show the other two parameters, you will need to add a file named `ide.host.json` to the 
`.template.config` folder. Below is a sample file that shows how to make those appear in Visual Studio.

```json
{
  "$schema": "http://json.schemastore.org/vs-2017.3.host",
  "icon": "icon.png",
  "symbolInfo": [
    {
      "id": "AuthorName",
      "name": {
        "text": "Author Name"
      },
      "isVisible": "true"
    },
    {
      "id": "Description",
      "name": {
        "text": "Description"
      },
      "isVisible": "true"
    }
  ]
}
```

After adding this declaration, when the template is used in Visual Studio the parameters
will be presented to the user as

![New Project Dialog - Additional Info Page](media/vs-addl-info-page.png)

## How to test template changes locally

In order for a template to appear in Visual Studio it needs to be installed using a NuGet package
(.nupkg file). When developing templates locally, when you are ready to test your template using
Visual Studio, follow the steps below.

It's recommended that you delete the cache folders that are used for the templates. The chache folders are in the user home directory under the `.templateengine` folder.

 1. Close all instances of Visual Studio
 1. Create a NuGet package that has the template
 1. Delete Template Engine cache folders
 1. Install the template using `dotnet new --install <path-to-nuget-package>`
 1. Start Visual Studio

## Common issues

If your template is not appearing in Visual Studio, check the following.

### Required properties

Ensure that the following required properties are set in the `template.json` file.

- `author`
- `sourceName`
- `classifications`
- `identity`
- `name`
- `shortName`
- `tags`

For tags ensure you have specified the `language` and `type` values. See the example below.

```json
  "tags": {
    "language": "C#",
    "type": "project"
  },
```

The `type` value can be either `project` or `item`, other values should not be used.

### `primaryOutputs`

If you have a single project template, you typically don't have to specify the `primaryOutputs` property.
If your `templates.json` file has specified `primaryOutputs`, Visual Studio will open load the project(s)
specified. If the value for `primaryOutputs` is not correct, the project(s) will not load in Visual Studio.

If the value for the `primaryOutputs` is not correct, the project(s) will not be loaded in Visual Studio

### Verify that the NuGet package has the correct files

After creating the .nupkg file you can examine it by extracting the contents using your favorite zip tool.
The .nupkg file is just a .zip file with a different file extension.
Double check that the `.template.config` folder is in the package as well as the `template.json` file
and any host files.
