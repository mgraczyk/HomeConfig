python3 << EndPython3
import collections
import os
import sys
import vim

def strtobool(text):
  if text.lower() in ['y', 'yes', 't', 'true', 'on', '1']:
    return True
  if text.lower() in ['n', 'no', 'f', 'false', 'off', '0']:
    return False
  raise ValueError(f"{text} is not convertible to boolean")

class Flag(collections.namedtuple("FlagBase", "name, cast")):
  @property
  def var_name(self):
    return self.name.replace("-", "_")

  @property
  def vim_rc_name(self):
    name = self.var_name
    if name == "line_length":
      name = name.replace("_", "")
    return "g:black_" + name


FLAGS = [
  Flag(name="line_length", cast=int),
  Flag(name="fast", cast=strtobool),
  Flag(name="skip_string_normalization", cast=strtobool),
  Flag(name="quiet", cast=strtobool),
  Flag(name="skip_magic_trailing_comma", cast=strtobool),
  Flag(name="preview", cast=strtobool),
]

import pyink as black
import time

def get_target_version(tv):
  if isinstance(tv, black.TargetVersion):
    return tv
  ret = None
  try:
    ret = black.TargetVersion[tv.upper()]
  except KeyError:
    print(f"WARNING: Target version {tv!r} not recognized by Black, using default target")
  return ret

def Black(**kwargs):
  """
  kwargs allows you to override ``target_versions`` argument of
  ``black.FileMode``.

  ``target_version`` needs to be cleaned because ``black.FileMode``
  expects the ``target_versions`` argument to be a set of TargetVersion enums.

  Allow kwargs["target_version"] to be a string to allow
  to type it more quickly.

  Using also target_version instead of target_versions to remain
  consistent to Black's documentation of the structure of pyproject.toml.
  """
  start = time.time()
  configs = get_configs()

  black_kwargs = {}
  if "target_version" in kwargs:
    target_version = kwargs["target_version"]

    if not isinstance(target_version, (list, set)):
      target_version = [target_version]
    target_version = set(filter(lambda x: x, map(lambda tv: get_target_version(tv), target_version)))
    black_kwargs["target_versions"] = target_version

  mode = black.FileMode(
    line_length=configs["line_length"],
    string_normalization=not configs["skip_string_normalization"],
    is_pyi=vim.current.buffer.name.endswith('.pyi'),
    magic_trailing_comma=not configs["skip_magic_trailing_comma"],
    preview=configs["preview"],
    is_pyink=True,
    pyink_indentation=2,
    **black_kwargs,
  )
  quiet = configs["quiet"]

  buffer_str = '\n'.join(vim.current.buffer) + '\n'
  try:
    new_buffer_str = black.format_file_contents(
      buffer_str,
      fast=configs["fast"],
      mode=mode,
    )
  except black.NothingChanged:
    if not quiet:
      print(f'Black: already well formatted, good job. (took {time.time() - start:.4f}s)')
  except Exception as exc:
    print(f'Black: {exc}')
  else:
    current_buffer = vim.current.window.buffer
    cursors = []
    for i, tabpage in enumerate(vim.tabpages):
      if tabpage.valid:
        for j, window in enumerate(tabpage.windows):
          if window.valid and window.buffer == current_buffer:
            cursors.append((i, j, window.cursor))
    vim.current.buffer[:] = new_buffer_str.split('\n')[:-1]
    for i, j, cursor in cursors:
      window = vim.tabpages[i].windows[j]
      try:
        window.cursor = cursor
      except vim.error:
        window.cursor = (len(window.buffer), 0)
    if not quiet:
      print(f'Black: reformatted in {time.time() - start:.4f}s.')

def get_configs():
  filename = vim.eval("@%")
  path_pyproject_toml = black.find_pyproject_toml((filename,))
  if path_pyproject_toml:
    toml_config = black.parse_pyproject_toml(path_pyproject_toml)
  else:
    toml_config = {}

  return {
    flag.var_name: toml_config.get(flag.name, flag.cast(vim.eval(flag.vim_rc_name)))
    for flag in FLAGS
  }


def BlackUpgrade():
  _initialize_black_env(upgrade=True)

def BlackVersion():
  print(f'Black, version {black.__version__} on Python {sys.version}.')

EndPython3

function black#Black(...)
    let kwargs = {}
    for arg in a:000
        let arg_list = split(arg, '=')
        let kwargs[arg_list[0]] = arg_list[1]
    endfor
python3 << EOF
import vim
kwargs = vim.eval("kwargs")
EOF
  :py3 Black(**kwargs)
endfunction

function black#BlackUpgrade()
  :py3 BlackUpgrade()
endfunction

function black#BlackVersion()
  :py3 BlackVersion()
endfunction
