---------------------------------------------------------------------
 <p align="center">
                                Dear/Undear<br>
                          	 Deduplicating Archiver
     </p>            <p align="center">             
                             by Solomon Jennings
</p>

---------------------------------------------------------------------

### INTRODUCTION:

This following set of tools written in bash and perl that create a deduplicated archive of a directory, it offers several compression methods.

To try for yourself :

<pre>
./dear -g <archive-name> <directory>
./undear -c <archive-name>.tar.gz
</pre>

### INSTALLING:
There are 2 packages that need to be installed for Dear and Undear to work.

The first is a perl package to md5 a file:

<code>sudo cpan install Digest::MD5::File</code>

The second is ncompress (install shown for ubuntu):

<code>sudo apt-get install ncompress</code>


## Dear:

#### To archive a folder

<code>./dear [compression method] [archive name] [directory]</code>

Compression Options are<br>
<code>-g</code> gzip compression<br>
<code>-b</code> bzip2 compression<br>
<code>-c</code> compress compression<br>

Or no switch to just create a tar file.

## Undear:

An archive can be uncompressed:
<code>./undear [duplicate method] [archive name]</code>

Duplicate Handling options are<br>
<code>-c</code> restore the duplicate<br>
<code>-l</code> symbolically link the duplicate<br>
<code>-d</code> remove any duplicate keeping only the first found original<br>

## SUPPORTED FUNCTIONALITY:
Dear works in the following way
1. A copy of the folder to archive is moved to a temporary directory (/tmp/) this is to avoid possible destruction of the original data
2. All duplicates are removed and a metadata file created with information on where the original file is located where to restore duplicates
3. the folder is archived removing files
4. The archive is moved to the output directory

Undear works in the following way
1. The archive is unpacked.
2. using the metadata file and the restore option provided the duplicates are restored
3. metadata is removed
4. folder is moved to correct location

Dedupliation happens in the following way
1. The input directory is traversed 
2. A MD5 hash is created for each file and stored in a Perl Hash table
3. If the MD5 already existed, the file is removed and it's location and the original location stored in a metadata file 

## Limitations:
* Filename with spaces *will* work
* Symbolic links will be deferenced as per -a switch of cp
* dear must be executed from the same directory of dupRemove.pl. However any input and output directory path can be passed to dear
* If the destination of the archive is within the folder to compress the archive will be created and then moved into the desired folder.
* There must be enough room on the disk to make a complete copy of the input folder and the archive
* The possibility of an MD5 clash can occur, but it is extremely low (unless specially crafted) this means a false duplicate may be detected
