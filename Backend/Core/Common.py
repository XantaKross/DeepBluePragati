import fitz  # PyMuPDF
import nltk
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from itertools import groupby
import rake_nltk
from copy import deepcopy
from nltk.corpus import wordnet
import os
import re

# MAX : 18 SECONDS. (FOR 300-600 PAGES)
# Current code scan and processing speed is about 23.03 pages/ second on average. AKA 23 pages per second.

#nltk.download('wordnet')

wnl = nltk.stem.WordNetLemmatizer()



def delete_file(file_path):
    """
    Deletes a file at the specified path.

    Args:
        file_path (str): The full path to the file to be deleted.

    Returns:
        None

    Raises:
        FileNotFoundError: If the specified file does not exist.
        OSError: If an error occurs during file deletion.
    """
    try:
        os.remove(file_path)
        print(f"File deleted: {file_path}")
    except OSError as e:
        print(f"Error deleting file: {e}")


def remove_unnecessary_words(text):
    """
    Removes stop words using NLTK library.
    Args:
        text: The string to process.
    Returns:
        A string with stop words removed.
    """
    # nltk.download('stopwords')  # Download stopwords resource (one-time)
    stop_words = nltk.corpus.stopwords.words('english')
    words = text.lower().split()

    return list(set(wnl.lemmatize(word) for word in words if word not in stop_words))


def get_related_words(phrase):
    phrase = phrase.lower().replace(" ", "_")
    synsets = wordnet.synsets(phrase)

    related_words = [phrase]
    for synset in synsets:
        # Get all lemmas (base forms) of the synset, synonyms, hypernyms and hyponyms
        adden = [lemma.name().replace("_", " ") for lemma in synset.lemmas()] + [synonym.replace("_", " ") for synonym in synset.lemma_names()]
        related_words.extend(adden)

        # Check for acronyms or abbreviations in the synset definition
        for definition in synset.definition():
            words = definition.split()
            for word in words:
                if word.lower() == phrase.replace("_", ""):
                    acronyms = [w for w in words if w.lower() != word.lower() and w.isupper()]
                    related_words.extend(acronyms)

    # Convert to lowercase, remove duplicates, and sort
    related_words = list(set(w.lower() for w in related_words))
    related_words.sort()

    return related_words

def extract_keywords(text):
    rake = rake_nltk.Rake()
    rake.extract_keywords_from_text(text)
    return list(set(rake.get_ranked_phrases()))


def suppress_2d(list_):
    """Suppresses duplicate empty strings between words in a list, keeping a single empty string.
    Args:
        list_: A list of strings.
    Returns:
        A new list with duplicate empty strings suppressed.
    """
    # compressed_list
    return [[k for k, g in groupby(row) if k != ''] for row in list_]


def suppress_1d(list_): return [k for k, g in groupby(list_) if k != '']

def read_pdf_adv(path,):
    pages = []

    with fitz.open(path) as doc:
        for page in doc:
            # x0, y0, x1, y1
            words = page.get_text("words")  # extract sorted words

            try:
                max_x, max_y = round(max([i[2] for i in words])), round(max([i[3] for i in words]))
                # Create a coordinate system.
                rec_page = [["" for i in range(max_x)] for j in range(max_y)]
                for i in words:
                    #               x0,          y0    =   sentence
                    rec_page[round(i[1])][round(i[0])] = i[4].replace("\n", "")

                # POSSIBLE RULE to implement later: If two coordinates/lines have same x coords they belong to the same column.
                # Hence must be appended with a | in between them.

                pages.append("\n".join(suppress_1d([" ".join(row) for row in suppress_2d(rec_page.copy()) if len(row) > 0 and len(list(row[0])) > 1])))


            except:
                print("SOFT WARNING: <PAGE EMPTY ENCOUNTERED>")
                print("Ignoring Page...")

    return pages

def naive_clean(list_pages):
    # final_pages = []
    #
    # for page in list_pages:
    #     if len(page) != 0:
    #         final_pages.append(" ".join(remove_unnecessary_words(page.strip())))
    return [" ".join(extract_keywords(page.strip().lower())) for page in list_pages if len(page) != 0]


def keyword_proximity_sort(words, list_):
    """
    Sorts a list of strings based on their proximity to numbers.

    Args:
        list_ (list): A list of strings.

    Returns:
        list: A sorted list of strings based on their proximity to numbers.
    """

    # Define a helper function to find the closest number in a string
    def find_closest_number(string):
        numbers = re.findall(r'\d+', string)

        word_pos = [x.start() for word in words for x in re.finditer(word, string)]
        if not numbers: return float('inf')  # Return infinity if no numbers are found
        min_distance = float('inf')

        for number in numbers:
            number_pos = string.index(number)

            print(number_pos, word_pos)
            print([(number_pos-widx)**2 for widx in word_pos])

            distance_list = [(number_pos-widx)**2 for widx in word_pos]

            if distance_list: closest_word_occurance_distance = min(distance_list)
            else: closest_word_occurance_distance = float('inf')

            if min_distance > closest_word_occurance_distance: min_distance = closest_word_occurance_distance

        return min_distance

    # Sort the list based on the proximity to numbers
    sorted_list = sorted(list_, key=find_closest_number)

    return sorted_list


def spread(x): return sum([1 for i in x if i!=0])

def func(x):
    y = x.tolist()
    return (sum(y) * spread(y)**2)

def broken_list(list_):
    k = []
    for i in list_: k+= i.split("_")
    return k

# Create WordNetLemmatizer object
# loc = "Docs/AnnualReportTata.pdf"

class Contexter:
    def __init__(self):
        self.tfIdfVectorizer = TfidfVectorizer(use_idf=True)
        self.result_size = 25 # 5
        self.bound = 1
        self.read = 0

    def read_file(self, loc):
        self.read = 1

        self.raw_pages = read_pdf_adv(loc)
        self.processed_pages = naive_clean(self.raw_pages)
        tfIdf = self.tfIdfVectorizer.fit_transform(self.processed_pages)
        self.tfidf_df = pd.DataFrame(tfIdf.toarray(), index=range(1, 1 + len(self.processed_pages)),
                                     columns=self.tfIdfVectorizer.get_feature_names_out())

    def get_context(self, query):
        """
        :param query: the query which must be used to process the context.
        :return: The context string from the document.
        """

        keyword_list = extract_keywords(query.lower())

        # Derivatives from keyword_list.
        processed_keyword_list = sum(map(str.split, keyword_list), []) #+ ["key"] # key will always be a keyword after now.
        extended_keyword_list = remove_unnecessary_words(" ".join(sum(map(str.split, sum([get_related_words(kw)for kw in keyword_list], [])) , [])))

        extended_keyword_list = broken_list(extended_keyword_list)
        print(extended_keyword_list)

        # find which of the keywords exist in the document.
        existing_columns = [col for col in extended_keyword_list if col in self.tfidf_df.columns]


        # create a copy of a subset of the document. (small chunk)
        df = deepcopy(self.tfidf_df[existing_columns]) # Get a copy of the frame of existing columns

        # print(processed_keyword_list) # this is basically the original user given keyword list.

        # Scale up the tf score of actual keywords.
        for kw in processed_keyword_list:
            if kw in df.columns:
                df[kw] *= 2 # scale up the score if the original keyword directly exists.

        # Calculate the average TF-IDF score for each row
        # Sort the DataFrame based on the average TF-IDF scores in descending order
        # Select the rows with the highest average TF-IDF scores
        top_rows = df.assign(split_tfidf=df.apply(func, axis=1)).sort_values(by='split_tfidf', ascending=False).head(10)

        # out of all the indexes. find a select few indexes.
        filtered_indexes = (top_rows.index - 1).tolist()[:self.result_size]
        grouped_pages = keyword_proximity_sort(processed_keyword_list, [self.raw_pages[pg_idx] for pg_idx in filtered_indexes])

        # function: --> takes in a input list of strings. unsorted.
        #           --> gives output another list of strings. sorted with respect to keyword proximity.

        def boolean(l1, s1): return bool([1 for i in l1 if i.lower() in s1.lower()])
        selected_pages = grouped_pages[:2] + [i for i in grouped_pages if boolean(["key", "highlight", "highlights"], i)][:1] # Taking only three pages.



        page_str_list = " ".join(selected_pages).split("\n")

        context_list = []
        for word in extended_keyword_list:
            for line_idx in range(len(page_str_list)):

                if word in page_str_list[line_idx].lower():
                    for line in page_str_list[line_idx - self.bound * (line_idx != 0): line_idx + (self.bound + 1)]:
                        if len(line.split()) > 1 and line not in context_list:
                            context_list.append(line)

        #max_size = 80
        return "\n".join(context_list)# [:max_size])


