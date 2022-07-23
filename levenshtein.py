import pandas as pd
from fuzzywuzzy import process


cmi_file = pd.read_excel(
    "C:/Users/ECHO TECH/Dropbox/Matching_Exercise/Ammad/cmi/excel files/cleaned/cmi.xls")
#importer_file = pd.read_excel("C:/Users/ECHO TECH/Dropbox/Matching_Exercise/Ammad/cmi/excel files/cleaned/uinque_ntn_importer.xlsx")
exporter_file = pd.read_excel(
    "C:/Users/ECHO TECH/Dropbox/Matching_Exercise/Ammad/cmi/excel files/cleaned/uinque_ntn_exporter.xls")

cmi = list(cmi_file.cleaned_3_duplicates_removed)
#importer = list(importer_file.cleaned_3_duplicates_removed)
exporter = list(exporter_file.cleaned_3_duplicates_removed)


def get_matches(query, choices, limit=1):
    results = process.extract(query, choices, limit=limit)
    return results


score1 = []
match1 = []
score2 = []
match2 = []


for names in exporter:
    match = get_matches(str(names), cmi)
    match1.append(match[0][0])
    score1.append(match[0][1])
    # match2.append(match[1][0])
    # score2.append(match[1][1])

df = pd.DataFrame({
    "Exporter": exporter,
    "cmi_1": match1,
    "score_1": score1
    # "cmi_2": match2,
    # "score_2": score2
})

df.to_excel("exporter_cmi_matches.xlsx")
