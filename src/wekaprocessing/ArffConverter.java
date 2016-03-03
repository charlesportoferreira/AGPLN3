/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package wekaprocessing;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author charles
 */
public class ArffConverter {

    public static void exec(String instancias, String atributos, String dataset) {
        try {
            deletaArquivoExistente(dataset);
            converteAtributos(atributos, dataset);
            converteDados(instancias, dataset);
            deletaArquivoExistente(atributos);
            deletaArquivoExistente(instancias);
        } catch (IOException ex) {
            Logger.getLogger(ArffConverter.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static void printFile(String fileName, String texto) throws IOException {

        try (FileWriter fw = new FileWriter(fileName, true); BufferedWriter bw = new BufferedWriter(fw)) {
            bw.write(texto);
            bw.close();
            fw.close();
        }
    }

    private static void converteAtributos(String fileName, String dataset) throws FileNotFoundException, IOException {
        String linha;
        String classe = "";
        StringBuilder sb = new StringBuilder();

        sb.append("@relation testeWeka \n\n");
        try (FileReader fr = new FileReader(fileName); BufferedReader br = new BufferedReader(fr)) {
            while (br.ready()) {
                linha = br.readLine();
                if (linha.contains("@@class@@")) {
                    classe = linha;
                }
                if (linha.contains("@attribute") && !linha.contains("@@class@@")) {
                    sb.append(linha).append("\n");
                }
            }
            br.close();
            fr.close();
            sb.append(classe);
            sb.append("\n\n@data\n");
            printFile(dataset, sb.toString());
        }
    }

    private static void converteDados(String fileName, String dataset) throws FileNotFoundException, IOException {

        String linha;
        String dados[];
        String dados2[];
        int val;
        int index;
        String classe;
        StringBuilder sb = new StringBuilder();
        try (FileReader fr = new FileReader(fileName); BufferedReader br = new BufferedReader(fr)) {
            while (br.ready()) {
                linha = br.readLine();
                if (linha.contains("@data")) {
                    while (br.ready()) {
                        classe = br.readLine();
                        linha = br.readLine();
                        if (linha.equals("{}")) {
                            sb.append("{").append(classe).append("}").append("\n");
                            continue;
                        }
                        linha = linha.replaceAll("\\{|\\}", "");
                        dados = linha.split(",");
                        sb.append("{");
                        for (String dado : dados) {
                            dados2 = dado.split(" ");
                            if (dados2[0].equals("0")) {
                                continue;
                            }
                            val = Integer.parseInt(dados2[0]);
                            val--;
                            sb.append(val).append(" ").append(dados2[1]).append(",");
                        }
                        sb.append(classe);
                        sb.append("}");
                        sb.append("\n");
                    }
                }
            }
            br.close();
            fr.close();
        }

        printFile(dataset, sb.toString());
    }

    public static void deletaArquivoExistente(String nomeArquivo) {
        File f = new File(nomeArquivo);
        if (f.exists()) {
            f.delete();
        }
    }

}
