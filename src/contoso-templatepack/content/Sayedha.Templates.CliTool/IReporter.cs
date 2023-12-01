namespace Contoso.Starter.Console {
    public interface IReporter {
        bool EnableVerbose { get; set; }
        void Write(string output);
        void WriteLine(string output);
        void WriteLine();
        void WriteLine(string output, string prefix);
        void WriteVerbose(string output);
        void WriteVerboseLine(string output, bool includePrefix = true);
        void WriteVerboseLine();
    }

    public class Reporter : IReporter {
        public bool EnableVerbose { get; set; }

        public void WriteLine() {
            Console.WriteLine();
        }
        public void WriteLine(string output) {
            Console.WriteLine(output);
        }
        public void Write(string output) {
            Console.Write(output);
        }
        public void WriteLine(string output, string prefix) {
            Console.Write(prefix);
            Console.WriteLine(output);
        }
        public void WriteVerboseLine() {
            if (EnableVerbose) {
                WriteLine();
            }
        }
        public void WriteVerboseLine(string output, bool includePrefix = true) {
            if (EnableVerbose) {
                if (includePrefix) {
                    Write("verbose: ");
                }
                Write(output);
                WriteLine();
            }
        }
        public void WriteVerbose(string output) {
            if (EnableVerbose) {
                Write(output);
            }
        }
    }
}
