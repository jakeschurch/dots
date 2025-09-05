    json5
    chromadb
    httpx
    numpy
    pathspec
    psutil
    pygments
    sentence-transformers
    shtab
    tabulate
    transformers
    tree-sitter
    tree-sitter-language-pack
  ];

  # Extra dependencies
  optional-dependencies = with python3Packages; {
    lsp = [
      lsprotocol
      pygls
    ];
    mcp = [
      mcp
      pydantic
    ];
  };

  # Combined dependencies
  allDeps =
    baseDeps
    ++ lib.optionals lspSupport optional-dependencies.lsp
    ++ lib.optionals mcpSupport optional-dependencies.mcp;

  # Python environment with all dependencies
  pythonWithDeps = python3.withPackages (_ps: allDeps);

in
python3Packages.buildPythonApplication rec {
  pname = "vectorcode";
  version = "0.6.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Davidyz";
    repo = "VectorCode";
    rev = version;
    hash = "sha256-yad8ChKEwSy1yFa8v+pGIKBoDxqbvr800wrhyMfedOM=";
  };

  build-system = with python3Packages; [ pdm-backend ];

  propagatedBuildInputs = allDeps;

  # Runtime wrapper configuration
  postFixup = ''
    wrapProgram $out/bin/vectorcode \
      --set PYTHONPATH "${pythonWithDeps}/${pythonWithDeps.sitePackages}" \
      --prefix PATH : "${lib.makeBinPath [ pythonWithDeps ]}"
  '';

  nativeCheckInputs = [
    versionCheckHook
    python3Packages.pytestCheckHook
  ]
  ++ allDeps;

  versionCheckProgramArg = "version";

  disabledTests = [
    "test_get_embedding_function"
    "test_get_embedding_function_fallback"
    "test_list_collections_no_metadata"
    "test_supported_rerankers_initialization"
    "test_get_reranker"
  ];

  pythonImportsCheck = [ "vectorcode" ];

  meta = {
    description = "Code repository indexing tool to supercharge your LLM experience";
    homepage = "https://github.com/Davidyz/VectorCode";
    changelog = "https://github.com/Davidyz/VectorCode/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "vectorcode";
  };
}
