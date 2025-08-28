/*[cpp] regex
#include <regex>
#include <string>

using namespace std;

cfunction double regex_match_c(char* text, char* pattern) {
	regex re(pattern);
    string str(text);
    return regex_search(str, re) ? 1.0 : 0.0;
}

cfunction char* regex_replace_c(char* text, char* pattern, char* replace) {
	regex re(pattern);
    string str(text);
    string repl(replace);
    string result = regex_replace(str, re, repl);
    char* cstr = new char[result.length() + 1];
    strcpy(cstr, result.c_str());
    return cstr;
}

cfunction char* regex_search_c(char* text, char* pattern) {
	regex re(pattern);
    string str(text);
    smatch match;

    if (regex_search(str, match, re)) {
        // Allocate memory for the result string
        string result;
        for (size_t i = 0; i < match.size(); ++i) {
            result += match[i].str();
            if (i < match.size() - 1) {
                result += "\n"; // Use newline as a separator
            }
        }
        char* cstr = new char[result.length() + 1];
        strcpy(cstr, result.c_str());
        return cstr;
    }

    return nullptr; // No match found
}
*/