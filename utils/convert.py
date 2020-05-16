import coremltools
import json
import numpy as np
import tfcoreml
from lib.punctuator import loadWordIndex


def save_mlmodel(coreml_model):
    coreml_model.author = 'Originally by Ottokar Tilk. Ported to Keras by Vaclav Kosar. Converted by Apollo Zhu'
    coreml_model.license = 'The MIT License (MIT)'
    coreml_model.short_description = 'Restore missing inter-word punctuation in unsegmented text.'
    coreml_model.save('punctuator.mlmodel')


def convertFreezedToCoreMLModel():
    mlmodel = tfcoreml.convert(
        tf_model_path='lib/model-data/freezed.pb',
        mlmodel_path='punctuator.mlmodel',
        input_name_shape_dict={'embedding_1_input':[1, 30]},
        output_feature_names=['dense_1/Softmax'],
        minimum_ios_deployment_target='13'
    )
    save_mlmodel(mlmodel)


def convertToWordIndexJSON():
    # https://stackoverflow.com/a/56243777/6142486
    np_load_old = np.load
    np.load = lambda *a,**k: np_load_old(*a, allow_pickle=True, **k)
    wordIndex = loadWordIndex()
    np.load = np_load_old

    with open('map.json', 'w') as output:
        json.dump(wordIndex,output, separators=(',', ':'))


if __name__ == "__main__":
    convertToWordIndexJSON()
    convertFreezedToCoreMLModel()
