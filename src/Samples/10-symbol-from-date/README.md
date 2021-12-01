The sample in this folder demonstrates:

 - Creating a parameter from the current date/time.

See 

 - [`template.json`](./MyProject.Con/.template.config/template.json)
 - [`Program.cs`](./MyProject.Con/Program.cs)

## `Program.cs` template source

```cs
using System;

namespace MyProject.Con
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(@"
Date created:         01/01/1999");
        }
    }
}
```

## `Program.cs` generated content

```cs
using System;

namespace MyProject.Con
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(@"
Date created:         12/01/2021");
        }
    }
}
```

Related
 - [Available parameter generators](https://github.com/dotnet/templating/wiki/Available-Parameter-Generators)
