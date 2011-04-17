/* The MIT License
 *
 * Copyright (c) 2010 OTClient, https://github.com/edubart/otclient
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#ifndef RESOURCES_H
#define RESOURCES_H

#include <prerequisites.h>

class Resources
{
public:
    Resources() { }

    void init(const char *argv0);
    void terminate();

    /// Sets the write directory
    bool setWriteDir(const std::string &path);

    /// Adds a directory or zip archive to the search path
    bool addToSearchPath(const std::string& path, bool insertInFront = true);

    /// Checks whether the given file exists in the search path
    bool fileExists(const std::string& filePath);

    /// Searches for zip files and adds them to the search path
    void searchAndAddArchives(const std::string &path,
                              const std::string &ext,
                              const bool append);

    /** Load a file by allocating a buffer and filling it with the file contents
     * where fileSize will be set to the file size.
     * The returned buffer must be freed with delete[]. */
    uchar *loadFile(const std::string &fileName, uint *fileSize);

    /// Loads a text file into a std::string
    std::string loadTextFile(const std::string &fileName);

    /// Save a file into write directory
    bool saveFile(const std::string &fileName, const uchar *data, uint size);

    /// Save a text file into write directory
    bool saveTextFile(const std::string &fileName, std::string text);

    /// Get a list with all files in a directory
    std::list<std::string> getDirectoryFiles(const std::string& directory);
};

extern Resources g_resources;

#endif // RESOURCES_H
