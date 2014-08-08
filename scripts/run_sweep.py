import subprocess
from tempfile import NamedTemporaryFile

def get_archstringlist(permutations):
    """ Permutations should be an iterable of pairs (name, values)
        where name is the name of the option to permute over, and
        values is an iterable of the values to permute over for that name.
    """
    if permutations:
        return "<archstring>\n{}\n</archstring>".format(
                "\n".join("{} = {}".format(n, " ".join(map(str, v))) for n,v in permutations))
    else:
        return ""


def run_sweep(testlist, permutations, simbin=None, resultsDir=None, timing=True, saveAll=False, local=False):
    passCmd = """\
    export LANGUAGE="en_US"
    export LC_ALL="C"
    export LANG="C"
    /prj/dsp/qdsp6/arch/scripts/pass -q6v v60 --h2 v60_latest --tools v60_latest --testlist {testlist} \
        {permutation_str} {results} --flags "TIMING='{timing}' PLIMIT='--plimit 0' {run}" --save {save} {local}
    """

    with NamedTemporaryFile("w+") as archstringF:
        archstringF.write(get_archstringlist(permutations))
        archstringF.flush()
        passArgs = {
                "testlist": testlist,
                "permutation_str": ("--archstringlist " + archstringF.name) if permutations else "",
                "results": ("--results " + resultsDir) if resultsDir else "",
                "timing": "--timing" if timing else " ",
                "save": "all" if saveAll else "stats",
                "run": 'RUN={}'.format(simbin) if simbin else "",
                "local": "--local" if local else ""
                }

        command = passCmd.format(**passArgs)
        print("Running:")
        print(command)
        subprocess.call(command, shell=True)

if __name__ == "__main__":
    run_sweep("fake_testlist", [("sweepme", range(2))], "resultDir")
