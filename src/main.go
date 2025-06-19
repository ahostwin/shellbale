// shellbale
// Copyright (C) 2025 ahost.win
//
// This file is part of shellbale.
//
// shellbale is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// shellbale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with shellbale.  If not, see <https://www.gnu.org/licenses/>.

package main

import (
	"crypto/sha256"
	"encoding/base64"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Version will be set during build using -ldflags
var Version = "dev"

const manPage = `NAME
    shellbale - generate shell scripts to recreate directory structures

SYNOPSIS
    shellbale [-h] [-v] [-t] -i INPUT_DIR [-o OUTPUT_SCRIPT]

DESCRIPTION
    shellbale creates a shell script that can recreate a directory structure
    including all files and subdirectories. Text files are preserved using
    heredoc strings while binary files are encoded using base64.

    If no output file is specified, the script will be written to stdout.

OPTIONS
    -h, --help
        Show help message and exit

    -v, --version
        Show program version

    -t, --tree
        Include ASCII tree representation

    -i INPUT_DIR, --input INPUT_DIR
        Input directory to process

    -o OUTPUT_SCRIPT, --output OUTPUT_SCRIPT
        Output script path (optional, defaults to stdout)

EXAMPLES
    shellbale -i ./my_folder -o recreate_folder.sh
    shellbale -i /path/to/project > backup.sh
    shellbale -i ./config -t | ssh remote_host "cat > restore_config.sh"
    shellbale -i ~/.config -t | xclip -selection clipboard`

func main() {
	var (
		showHelp    bool
		showVersion bool
		showTree    bool
		inputDir    string
		outputFile  string
	)

	flag.BoolVar(&showHelp, "h", false, "Show help message")
	flag.BoolVar(&showVersion, "v", false, "Show version")
	flag.BoolVar(&showTree, "t", false, "Include ASCII tree representation")
	flag.StringVar(&inputDir, "i", "", "Input directory")
	flag.StringVar(&outputFile, "o", "", "Output script file (optional, defaults to stdout)")

	flag.Parse()

	if showHelp {
		fmt.Println(manPage)
		os.Exit(0)
	}

	if showVersion {
		fmt.Printf("shellbale version %s\n", Version)
		os.Exit(0)
	}

	if inputDir == "" {
		fmt.Println("Error: Input directory (-i) is required")
		fmt.Println("Use -h for help")
		os.Exit(1)
	}

	var out io.WriteCloser = os.Stdout
	if outputFile != "" {
		f, err := os.Create(outputFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: failed to create output file: %v\n", err)
			os.Exit(1)
		}
		out = f
	}
	defer out.Close()

	if err := generateScript(inputDir, out, showTree); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

type treeNode struct {
	name     string
	isDir    bool
	children []*treeNode
}

func buildTree(root string) (*treeNode, error) {
	rootInfo, err := os.Stat(root)
	if err != nil {
		return nil, err
	}
	_ = rootInfo

	rootNode := &treeNode{
		name:     filepath.Base(root),
		isDir:    true,
		children: make([]*treeNode, 0),
	}

	err = filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if path == root {
			return nil
		}

		relPath, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}

		parts := strings.Split(relPath, string(os.PathSeparator))
		currentNode := rootNode
		for i, part := range parts {
			isLast := i == len(parts)-1
			found := false
			for _, child := range currentNode.children {
				if child.name == part {
					currentNode = child
					found = true
					break
				}
			}
			if !found {
				newNode := &treeNode{
					name:     part,
					isDir:    !isLast || info.IsDir(),
					children: make([]*treeNode, 0),
				}
				currentNode.children = append(currentNode.children, newNode)
				currentNode = newNode
			}
		}
		return nil
	})

	return rootNode, err
}

func renderTree(node *treeNode, prefix string, isLast bool, sb *strings.Builder) {
	// Sort children by name
	sort.Slice(node.children, func(i, j int) bool {
		// Directories come first, then files
		if node.children[i].isDir != node.children[j].isDir {
			return node.children[i].isDir
		}
		return node.children[i].name < node.children[j].name
	})

	// Print current node
	if prefix == "" {
		sb.WriteString(node.name + "/\n")
	} else {
		sb.WriteString(prefix)
		if isLast {
			sb.WriteString("└── ")
		} else {
			sb.WriteString("├── ")
		}
		sb.WriteString(node.name)
		if node.isDir {
			sb.WriteString("/")
		}
		sb.WriteString("\n")
	}

	// Print children
	for i, child := range node.children {
		newPrefix := prefix
		if isLast {
			newPrefix += "    "
		} else {
			newPrefix += "│   "
		}
		renderTree(child, newPrefix, i == len(node.children)-1, sb)
	}
}

func countItems(node *treeNode) (dirs int, files int) {
	if node.isDir {
		dirs++
	} else {
		files++
	}
	for _, child := range node.children {
		d, f := countItems(child)
		dirs += d
		files += f
	}
	return
}

func generateScript(inputDir string, out io.Writer, showTree bool) error {
	// Write script header
	fmt.Fprintf(out, "#!/bin/sh\n# built using shellbale version %s\n\n", Version)

	// Generate and write tree if requested
	if showTree {
		tree, err := buildTree(inputDir)
		if err != nil {
			return fmt.Errorf("failed to generate tree: %w", err)
		}

		var sb strings.Builder
		renderTree(tree, "", true, &sb)
		dirs, files := countItems(tree)
		// Subtract 1 from dirs to not count the root directory twice
		sb.WriteString(fmt.Sprintf("\n%d directories, %d files\n", dirs-1, files))

		fmt.Fprintf(out, "cat << \\__TREE > /dev/null\n")
		fmt.Fprintf(out, "%s", sb.String())
		fmt.Fprintf(out, "__TREE\n\n")
	}

	// Walk through the directory
	return filepath.Walk(inputDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Get relative path
		relPath, err := filepath.Rel(inputDir, path)
		if err != nil {
			return fmt.Errorf("failed to get relative path: %w", err)
		}

		// Skip the root directory
		if relPath == "." {
			return nil
		}

		// Create directory if needed
		if info.IsDir() {
			fmt.Fprintf(out, "\nmkdir -p %q", relPath)
			// Only set directory permissions if they differ from default 755
			mode := info.Mode() & os.ModePerm
			if mode != 0755 {
				fmt.Fprintf(out, "\nchmod %o %q", mode, relPath)
			}
			return nil
		}

		// Handle file
		return processFile(out, path, relPath, info)
	})
}

func processFile(out io.Writer, path, relPath string, info os.FileInfo) error {
	// Generate unique heredoc delimiter
	ext := filepath.Ext(path)
	if ext == "" {
		ext = filepath.Base(path)
	}
	delimiter := fmt.Sprintf("__EOF_%s_%d", strings.ToUpper(strings.TrimPrefix(ext, ".")), info.ModTime().Unix())

	// Write file creation
	fmt.Fprintf(out, "\n\nFILEPATH=%q\n", relPath)
	fmt.Fprintf(out, "touch \"$FILEPATH\"\n")

	// Set permissions if they differ from default 644
	mode := info.Mode() & os.ModePerm
	if mode != 0644 {
		fmt.Fprintf(out, "chmod %o \"$FILEPATH\"\n", mode)
	}

	// Read file content
	content, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("failed to read file %s: %w", path, err)
	}

	// Skip empty files
	if len(content) == 0 {
		return nil
	}

	// Check if file is binary
	isBinary := isBinaryContent(content)

	if isBinary {
		// Handle binary file
		hash := sha256.Sum256(content)
		fmt.Fprintf(out, "EXPECTED_HASH=%x\n", hash)
		fmt.Fprintf(out, "cat <<\\%s | base64 -d > \"$FILEPATH\"\n", delimiter)
		encoder := base64.NewEncoder(base64.StdEncoding, out)
		encoder.Write(content)
		encoder.Close()
		fmt.Fprintf(out, "\n%s\n", delimiter)

		// Add hash verification
		fmt.Fprintf(out, "COMPUTED_HASH=$(sha256sum \"$FILEPATH\" | cut -d' ' -f1)\n")
		fmt.Fprintf(out, "if [ \"$COMPUTED_HASH\" != \"$EXPECTED_HASH\" ]; then\n")
		fmt.Fprintf(out, "    echo \"Hash does not match for $FILEPATH!\"\n")
		fmt.Fprintf(out, "fi\n")
	} else {
		// Handle text file
		fmt.Fprintf(out, "cat <<\\%s > \"$FILEPATH\"\n", delimiter)
		out.Write(content)
		// Ensure content ends with a newline before the delimiter
		if len(content) > 0 && content[len(content)-1] != '\n' {
			fmt.Fprintln(out)
		}
		fmt.Fprintf(out, "%s\n", delimiter)
	}

	return nil
}

func isBinaryContent(content []byte) bool {
	if len(content) == 0 {
		return false
	}

	// Check for null bytes and high concentration of non-printable characters
	nullCount := 0
	nonPrintable := 0
	for _, b := range content[:min(len(content), 512)] { // Check first 512 bytes
		if b == 0 {
			nullCount++
		}
		if b < 32 && b != 9 && b != 10 && b != 13 { // Not tab, LF, or CR
			nonPrintable++
		}
	}

	// Consider binary if there are null bytes or high concentration of non-printable chars
	return nullCount > 0 || float64(nonPrintable)/float64(min(len(content), 512)) > 0.3
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
} 
