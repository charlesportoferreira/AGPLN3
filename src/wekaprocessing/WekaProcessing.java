/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package wekaprocessing;

import weka.core.*;
import weka.core.converters.*;
import weka.filters.*;
import weka.filters.unsupervised.attribute.*;

import java.io.*;
import weka.core.stemmers.SnowballStemmer;

/**
 *
 * @author charles
 */
public class WekaProcessing {
    
    public static Instances exec(String stoplistName) throws Exception {
        String diretorio = System.getProperty("user.dir");
        diretorio += "/dataset";

        TextDirectoryLoader loader = new TextDirectoryLoader();
        loader.setDirectory(new File(diretorio));
        Instances dataRaw = loader.getDataSet();

        StringToWordVector filter = new StringToWordVector();

        filter.setIDFTransform(true);
//        filter.setTFTransform(true);
        filter.setStopwords(new File(stoplistName));
        filter.setWordsToKeep(9000);
        filter.setOutputWordCounts(true);
        filter.setUseStoplist(true);

        filter.setStemmer(new SnowballStemmer());
        filter.setInputFormat(dataRaw);
        dataRaw = Filter.useFilter(dataRaw, filter);

        return dataRaw;

    }

 

   
}
