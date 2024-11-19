--------------------------------------------------------------------------------
--                             yicks for NeoVim                               --
--                               by simirian                                  --
--------------------------------------------------------------------------------

-- performance redefinitions
local set_hl = vim.api.nvim_set_hl
local dcpy = vim.deepcopy
local next = next
local type = type

local H = {}
local M = {}

-- color scheme definitions {{{1

-- colors{} {{{2

--- The base colors for the color scheme.
--- @type { light: { [string]: string }, dark: { [string]: string } }
M.colors = {
  light = {
    red     = "#b0433b",
    orange  = "#b0723b",
    yellow  = "#a69a3e",
    green   = "#5f9a37",
    cyan    = "#399d88",
    blue    = "#4c82b8",
    violet  = "#8f3db4",
    magenta = "#b03b99",
  },
  dark = {
    red     = "#903731",
    orange  = "#905d31",
    yellow  = "#887e31",
    green   = "#4e7e2d",
    cyan    = "#2f816f",
    blue    = "#3a648f",
    violet  = "#753293",
    magenta = "#90317d",
  },
}

-- Yicks.Scheme {{{2

--- @class Yicks.Scheme
--- The base colors for the scheme. This should be a gradient of 6 colors from
--- darkest to lightest.
--- - 1: background
--- - 2: in-window decorations, popup backgrounds
--- - 3: selection, window separators, in-popup decorations
--- - 6: virtual characters, comments
--- - 7: normal text
--- - 8: callout text
--- @field dark string[]
--- Just like dark but for when 'background' is light. Of course, the gradient
--- should be reversed.
--- @field light string[]
--- The accent colors to be used for this scheme. Expects four color names.
--- @field accents string[]

-- yicks_yellow{} {{{2

--- The default yellow yicks scheme.
--- @type Yicks.Scheme
M.yicks_yellow = {
  dark = {
    "#272220",
    "#322c2a",
    "#433c37",
    "#7b6d65",
    "#9a8c84",
    "#b3ada2",
  },
  light = {
    "#b3ada2",
    "#a59e92",
    "#978982",
    "#615851",
    "#433c37",
    "#272220",
  },
  accents = { "yellow", "red", "orange", "green" },
}

-- yicks_blue{} {{{2

--- The blue yicks variant.
--- @type Yicks.Scheme
M.yicks_blue = {
  dark = {
    "#201e24",
    "#2d2b31",
    "#3b3843",
    "#676f79",
    "#818a98",
    "#a0abb1",
  },
  light = {
    "#a0abb1",
    "#939aab",
    "#818a98",
    "#51515e",
    "#39394e",
    "#1f1f24",
  },
  accents = { "blue", "magenta", "cyan", "violet" },
}

-- yicks_green{} {{{2

--- The green yicks variant.
--- @type Yicks.Scheme
M.yicks_green = {
  dark = {
    "#1d211c",
    "#2a2f28",
    "#393f36",
    "#617660",
    "#829782",
    "#a0b1a0",
  },
  light = {
    "#a0b1a0",
    "#90a290",
    "#829782",
    "#50574c",
    "#393f36",
    "#1d211c",
  },
  accents = { "green", "cyan", "yellow", "blue" }
}

-- helpers {{{1

-- H.p{} {{{2

--- Stores the currently active palette. Values are of the form cv where c is
--- the category and v is the value.
--- eg. b3 = #666666 for setting base 3
--- Categories are:
--- - b: bases
--- - a: accents
--- - A: alternate accents
--- - c: colors
--- - C: alternate colors
--- c/C adn a/A differ in lgiht/dark ness
--- @type { [string]: string }
H.p = {}

-- H.makep() {{{2

--- Generates the palette which will be used by H.hl() to actually set
--- highlights.
--- @param scheme Yicks.Scheme The scheme to cenerate a palette for.
function H.makep(scheme)
  local primary = vim.o.background == "light"
      and M.colors.dark or M.colors.light
  local secondary = vim.o.background == "light"
      and M.colors.light or M.colors.dark
  for i, v in ipairs(scheme[vim.o.background]) do
    H.p["b" .. i] = v
  end
  for i, v in ipairs(scheme.accents) do
    H.p["a" .. i] = primary[v]
    H.p["A" .. i] = secondary[v]
  end
  for _, v in pairs({
    "red", "orange", "yellow", "green", "cyan", "blue", "violet", "magenta"
  }) do
    H.p["c" .. v:sub(1, 1)] = primary[v]
    H.p["C" .. v:sub(1, 1)] = secondary[v]
  end
end

-- Yicks.Highlight {{{2

--- Represents a highlight that yicks can use. In the string form, it should be
--- the name of a group to link to. In the table form, it should be an
--- acceptable argument to nvim_set_hl(), except every color name is replaced
--- with a H.p{} color name.
--- @alias Yicks.Highlight string|vim.api.keyset.highlight

-- H.hl() {{{2

--- Highlights a group with the given options.
--- @param group string The group to highlight.
--- @param hl Yicks.Highlight How to highlight that group.
function H.hl(group, hl)
  local arg
  if type(hl) == "string" then
    arg = { link = hl }
  elseif next(hl) == nil then
    arg = { default = true }
  else
    arg = dcpy(hl)
    arg.fg = H.p[hl.fg]
    arg.bg = H.p[hl.bg]
    arg.sp = H.p[hl.sp]
  end
  set_hl(0, group, arg)
end

-- H.highlights{} {{{1

--- The highlights that yicks will set.
--- @type { [string]: Yicks.Highlight }
H.highlights = {
  -- metahighlights {{{2
  Unknown = { fg = "cg", bg = "cm" },
  Error = { fg = "cr" },
  Warning = { fg = "co" },
  Info = { fg = "cb" },
  Hint = { fg = "cc" },
  Ok = { fg = "cg" },

  QuickFixLine = { fg = "cg", bg = "b2" },
  Directory = { fg = "a1" },

  -- cursor {{{2
  Cursor = { fg = "b6", bg = "b1", reverse = false },
  lCursor = "Cursor",
  CursorIM = "Cursor",
  CursorLine = { bg = "b2" },
  CursorColumn = "CursorLine",
  ColorColumn = "CursorLine",
  TermCursor = { reverse = true },
  TermCursorNC = "TermCursor",

  -- diff groups {{{2
  DiffAdd = { fg = "b1", bg = "cg" },
  DiffChange = { fg = "b1", bg = "cc" },
  DiffDelete = { fg = "b1", bg = "cr" },
  DiffText = { fg = "b1", bg = "b6" },

  -- search {{{2
  Search = { fg = "b1", bg = "a3" },
  CurSearch = { fg = "b1", bg = "a3" },
  IncSearch = "CurSearch",
  Substitute = "CurSearch",

  -- left column {{{2
  LineNr = { fg = "b4" },
  LineNrAbove = "LineNr",
  LineNrBelow = "LineNr",
  CursorLineNr = { fg = "A1" },

  FoldColumn = "Normal",
  CursorLineFold = "CursorLineSign",

  SignColumn = "Normal",
  CursorLineSign = "CursorLineNr",

  -- text {{{2
  Normal = { fg = "b5", bg = "b1" },
  NormalNC = "Normal",
  Conceal = { fg = "b4", bg = "" },
  NonText = { fg = "b4" },
  Whitespace = "NonText",
  SpecialKey = "NonText",
  EndOfBuffer = "NonText",
  Folded = { fg = "b4", bg = "b3" },
  MatchParen = { fg = "b6", bg = "" },

  -- messages {{{2
  MsgArea = "Normal",
  ErrorMsg = { fg = "b1", bg = "cr" },
  WarningMsg = { fg = "b1", bg = "co" },
  ModeMsg = { fg = "cy" },
  MsgSeparator = { fg = "b5", bg = "b3" },
  MoreMsg = { fg = "cb" },
  Question = "MoreMsg",

  -- floats and windows {{{2
  Title = { fg = "a1" },
  WinSeparator = { fg = "b4", bg = "b3" },
  NormalFloat = { fg = "b5", bg = "b2" },
  FloatTitle = "NormalFloat",
  FloatBorder = { fg = "b4", bg = "b2" },

  -- lines {{{2
  StatusLine = { fg = "a1", bg = "b3", reverse = false },
  StatusLineNC = { fg = "b5", bg = "b3", reverse = false },
  WinBar = "StatusLine",
  WinBarNC = "StatusLineNC",
  TabLine = "StatusLineNC",
  TabLineFill = "TabLine",
  TabLineSel = { fg = "a1", bg = "b1" },
  User1 = { fg = "b1", bg = "a1" },
  User2 = { fg = "a1", bg = "b2" },
  User3 = { fg = "a2", bg = "b2" },
  User4 = { fg = "a3", bg = "b2" },
  User5 = { fg = "a4", bg = "b2" },

  -- popup menus {{{2
  Pmenu = { fg = "b5", bg = "b2" },
  PmenuSel = { fg = "a1", bg = "b3" },
  PmenuKind = "Pmenu",
  PmenuKindSel = "PmenuSel",
  PmenuExtra = "Pmenu",
  PmenuExtraSel = "PmenuSel",
  PmenuSbar = { bg = "b3" },
  PmenuThumb = { bg = "A1" },
  WildMenu = "PmenuSel",

  -- spellcheck {{{2
  SpellBad = { sp = "cr", undercurl = true },
  SpellCap = { sp = "cy", underdashed = true },
  SpellLocal = { sp = "cg", underdashed = true },
  SpellRare = { sp = "cc", underdashed = true },

  -- selections {{{2
  Visual = { bg = "b3" },
  VisualNOS = "Visual",

  -- code groups {{{2
  Comment = { fg = "b4" },

  -- variables {{{3
  Constant = { fg = "A1" },
  Variable = { fg = "a1" },
  String = { fg = "A4" },
  Character = { fg = "a4" },
  Boolean = { fg = "A2" },
  Number = { fg = "A3" },
  Float = { fg = "A3" },

  Identifier = { fg = "b5" },
  Function = { fg = "a3" },

  -- keywords {{{3
  Statement = { fg = "a2" },
  Operator = { fg = "A2" },
  Conditional = "Statement",
  Repeat = "Statement",
  Label = "Statement",
  Keyword = "Statement",
  Exception = "Statement",

  -- preproc {{{3
  PreProc = { fg = "a3" },
  Include = "PreProc",
  Define = "PreProc",
  Macro = "PreProc",
  PreCondit = "PreProc",

  -- types {{{3
  Type = { fg = "a3" },
  StorageClass = "Type",
  Structure = "Type",
  Typedef = "Type",

  -- special {{{2
  Special = "Delimiter",
  SpecialChar = "Character",
  Tag = { fg = "a4" },
  Delimiter = { fg = "b5" },
  SpecialComment = { fg = "A1" },
  Debug = { fg = "cc" },
  Underlined = { underline = true },
  Ignore = { italic = true, fg = "b4" },
  Todo = { fg = "cp" },

  -- diagnostics {{{2
  DiagnosticError = "Error",
  DiagnosticWarn = "Warning",
  DiagnosticInfo = "Info",
  DiagnosticHint = "Hint",
  DiagnosticOk = "Ok",

  DiagnosticUnderlineError = { sp = "cr", undercurl = true },
  DiagnosticUnderlineWarn = { sp = "co", undercurl = true },
  DiagnosticUnderlineInfo = { sp = "cb", undercurl = true },
  DiagnosticUnderlineHint = { sp = "cc", undercurl = true },
  DiagnosticUnderlineOk = { sp = "cg", undercurl = true},

  -- telescope {{{2
  TelescopeNormal = { fg = "b5", bg = "b2" },
  TelescopeBorder = { fg = "b2", bg = "b2" },
  TelescopeTitle = "TelescopeBorder",
  TelescopePromptNormal = { fg = "b5", bg = "b3" },
  TelescopePromptBorder = { fg = "b3", bg = "b3" },
  TelescopePromptTitle = "TelescopePromptBorder",

  -- nvim-tree {{{2
  NvimTreeSignColumn = "NormalFloat",

  -- treesitter {{{2
  ["@variable"] = "Variable",
  ["@lsp.type.variable"] = "Variable",
  ["@label"] = { fg = "a4" },
  ["@punctuation"] = { fg = "b5" },
  ["@markup.link"] = { fg = "a4" },
  ["@markup.raw"] = { fg = "b4" },

  -- contour {{{2
  ContourDiagnosticError = { fg = "cr", bg = "b2" },
  ContourDiagnosticWarn = { fg = "co", bg = "b2" },
  ContourDiagnosticInfo = { fg = "cb", bg = "b2" },
  ContourDiagnosticHint = { fg = "cc", bg = "b2" },
}

-- module {{{1

-- yicks.set() {{{2

--- The name of the last scheme that was set.
--- @type string
H.last_scheme = nil

--- Sets the color scheme to the one defined on this module with the given name.
--- Defaults to the last chosen theme, or yellow if there is none.
--- @param opts? string|Yicks.Scheme The scheme to use.
--- @return boolean success
function M.set(opts)
  opts = opts or H.last_scheme or "yicks_yellow"
  if type(opts) == "string" then
    if not M[opts] then return false end
    H.makep(M[opts])
    H.last_scheme = opts
  else
    H.makep(opts)
  end
  vim.cmd("hi clear")

  for group, hl in pairs(H.highlights) do
    H.hl(group, hl)
  end

  vim.g.colors_name = "yicks"
  return true
end

-- yicks.setup() {{{2

--- So complex, much wow. Just does :colorscheme.
--- @param opts? string|Yicks.Scheme|{ [1]: string|Yicks.Scheme } The scheme to use, or name of one to use.
function M.setup(opts)
  if type(opts) == "table" and opts[1] then opts = opts[1] end
  if opts == "yicks" then opts = nil end
  if M.set(opts) then
    vim.api.nvim_exec_autocmds("ColorScheme", {
      pattern = type(opts) == "string" and opts or "yicks"
    })
  end
end

return M
-- vim:fdm=marker
