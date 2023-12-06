using System.CommandLine;
using System.CommandLine.Invocation;

namespace Contoso.Starter.Console {
    public static class CommandExtenions {
        /// <summary>
        /// Allows the command handler to be included in the collection initializer.
        /// </summary>
        public static void Add(this Command command, ICommandHandler handler) {
            command.Handler = handler;
        }
    }
}
