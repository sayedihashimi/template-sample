using System;

namespace MyCommand {
    public class Program {
        static void Main(string[] args) {
            Console.WriteLine("Hello World! Description: DescriptionContent Author: AuthorName.");
            
            // Below demonstrates how sourceName replacements will try to automatically
            // detect the format of the output. For example below, you can see the string MyCommand, which is the sourceName
            // for this template. Below that, you'll see the lower case version of it.
            // When the template is executed and a name is given, it will be lowercase in the second line of code.
            // Some related info at https://github.com/dotnet/templating/wiki/Naming-and-default-value-forms
            Console.WriteLine("Standard: MyCommand");
            Console.WriteLine("Lower: mycommand");
        }
    }
}
