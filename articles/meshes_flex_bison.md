% Loading Polygon Meshes with Flex/Bison
% Jonathan Glines
% 2016

This isn't a terribly remarkable subject, but loading polygon meshes is where
many graphics projects begin.  This article documents some of the techniques
I've used to load meshes using the flex/bison parser tools, as well as some of
the pitfalls I've run into. [@WatsonCrick1953; @Deloura:2000:GPG:572747]

I have published some example polygon mesh loading code in git repositories
linked at the bottom of this page. My code is free to use under a permissive
license, but for most people I would suggest writing one's own polygon mesh
parser. My implementation is not intended to be a general-purpose model loading
library (for that, see
[OpenCOLLADA](https://github.com/KhronosGroup/OpenCOLLADA) or
[assimp](https://github.com/assimp/assimp)).

## Introduction

The motivation for using a DIY mesh solution (as opposed to an off-the-shelf
mesh library) is apparent when one is faced with supporting a custom asset.
That said, the path of least resistance is to leverage existing conventional
formats.  A mesh file parser usually starts by
supporting the useful subset of a mesh format that most modeling tools can
readily export (`.OBJ`, `.PLY`, etc.).

## Choosing a Polygon Mesh File Format
Polygon mesh formats are often complicated by application-specific
requirements; things like material properties, animation data, and mesh
topology. Accordingly, there is no shortage of complicated formats in which to
store meshes. Just take a look at [this table of polygon mesh formats on
Wikipedia](https://en.wikipedia.org/wiki/Polygon_mesh#File_formats). Clearly, our first task is deciding which of these is appropriate for us. There is no 

Most popular polygon mesh formats come with some form of ASCII text
representation.  These are the easiest to work with. Unfortunately, they are
also the least performant when in comes to loading times. [Conventional
programming
wisdom](https://shreevatsa.wordpress.com/2008/05/16/premature-optimization-is-the-root-of-all-evil/)
tells us that performance should not be a concern at the outset of a project.
Thus, we start with these easy-to-debug ASCII formats. If performance becomes
an issue down the line, serializing the polygon mesh should be a
straightforward optimization (we are parsing the mesh data ourselves, after
all).

Here is a list of the mesh formats that I am familiar with.

  - **Stanford PLY**&mdash;Probably the simplest mesh format. Typically only
  used for triangle meshes. Many 3D scans are available for download as `.ply`
  files from [Stanford's
  repository](http://graphics.stanford.edu/data/3Dscanrep/).
  - **Wavefront OBJ**&mdash;something something

Honestly, any of these formats is as good as the last. What works best is
usually determined by the tools you have for creating and using polygon mesh
assets.

## Scanning and Parsing

### Parsing `.OBJ`

### Parsing `.PLY`

## Designing a Mesh Loader

### Tracking Parser State

Most mesh formats include some sort of preamble or header section, used to declare attributes of the mesh data. Thus, we need some sort of "symbol table" in which to record what was declared in the header. We can use that information to validate the rest of the mesh data.

In essence, the parser must "remember" certain things&mdash;the number of
declared vertices, faces, attributes, etc.&mdash;in order to properly
parse the mesh data. This is an important point; **we cannot encode
knowledge of the header directly into a bison grammar**. We need to provide
bison with additional structures (basically a symbol table) so that it can
use knowledge of the header while parsing the rest of the file.

In my code, I use classes named `*Parser`. They could just as easily be named `*Header` or `*SymbolTable`. The declaration for the `*Parser` class I use for parsing `.PLY` files is given below.

~~~{.cpp}
class PlyParser {
  private:
    MeshBuilder *m_builder;
    std::vector<std::vector<float>> m_vertices;
  public:
    PlyParser();
    ~PlyParser();
};
~~~

Note that most of the data structures in this class are of specific concern to `.PLY` mesh parsers. In particular, the 


### Decoupling Input and Output Formats

The result of parsing a mesh data file is really just a stream of vertices, faces, and attributes. Most applications will need 

~~~{.cpp}
class MeshBuilder {
  public:
    MeshBuilder();
    virtual ~MeshBuilder();

    virtual void vertex(const glm::vec4 &position) = 0;
    virtual void face(const std::vector<int> vertices) = 0;
};
~~~

### Serializing Polygon Mesh Data (For Performance)
Parsing ASCII polygon mesh data, especially the data 

I can't recommend parsing binary data with flex/bison, as that is not what they are designed to do.

## Notes on Using Flex/Bison
Admitedly, flex/bison isn't the most intuitive. 

### Alternatives to Flex/Bison
I use flex/bison because it's readily available.

## References

---
references:
- type: article-journal
  id: WatsonCrick1953
  author:
  - family: Watson
    given: J. D.
  - family: Crick
    given: F. H. C.
  issued:
    date-parts:
    - - 1953
      - 4
      - 25
  title: 'Molecular structure of nucleic acids: a structure for deoxyribose
    nucleic acid'
  title-short: Molecular structure of nucleic acids
  container-title: Nature
  volume: 171
  issue: 4356
  page: 737-738
  DOI: 10.1038/171737a0
  URL: http://www.nature.com/nature/journal/v171/n4356/abs/171737a0.html
  language: en-GB
---
