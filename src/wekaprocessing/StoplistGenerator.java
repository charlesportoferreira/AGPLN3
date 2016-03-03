/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package wekaprocessing;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author charles
 */
public class StoplistGenerator {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        List<String> ls = new ArrayList<>();
        ls.add("VB.text");
        ls.add("EX.text");
        try {
            generate(ls, "stoplist.text");
        } catch (IOException ex) {
            Logger.getLogger(StoplistGenerator.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static void generate(List<String> stoplists, String stoplistName) throws FileNotFoundException, IOException {
        String diretorio = System.getProperty("user.dir");
        diretorio += "/stoplist/";
        String linha;
        StringBuilder sb = new StringBuilder();
        for (String stoplist : stoplists) {
            try (FileReader fr = new FileReader(diretorio + stoplist); BufferedReader br = new BufferedReader(fr)) {
                while (br.ready()) {
                    linha = br.readLine();
                    if (linha.length() < 1) {
                        continue;
                    }
                    sb.append(linha).append("\n");
                }
                br.close();
                fr.close();

                printFile(stoplistName, sb.toString());
            }
        }

    }

    public static void printFile(String fileName, String texto) throws IOException {

        try (FileWriter fw = new FileWriter(fileName); BufferedWriter bw = new BufferedWriter(fw)) {
            bw.write(texto);
            // bw.newLine();
            bw.close();
            fw.close();
        }
    }

}
