package com.tib.util;

import com.fasterxml.jackson.databind.MappingIterator;
import com.fasterxml.jackson.databind.ObjectReader;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvParser;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import org.json.simple.JSONObject;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class CSVToJsonTransformer {

    private CsvMapper mapper;

    public CSVToJsonTransformer() {
        mapper = new CsvMapper();
        mapper.enable(CsvParser.Feature.TRIM_SPACES);
    }

    public String transform(String csvContent, TransformOptions transformOptions) {

        CsvSchema schema = getCsvSchema(transformOptions);

        String jsonString = "";
        System.out.println("Transforming...");
        try {
            ObjectReader objectReader = mapper.reader(HashMap.class).with(schema);

            MappingIterator<Map<String, String>> it = objectReader.readValues(csvContent.getBytes("UTF-8"));

            jsonString = getJsonString(it);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return jsonString;
    }

    public String transform(File csvFile, TransformOptions transformOptions) {
        CsvSchema schema = getCsvSchema(transformOptions);

        String jsonString = "";
        System.out.println("Transforming from file..");
        try {
            ObjectReader objectReader = mapper.reader(HashMap.class).with(schema);

            
            MappingIterator<Map<String, String>> it = objectReader.readValues(csvFile);
            jsonString = getJsonString(it);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return jsonString;
    }

    private CsvSchema getCsvSchema(TransformOptions transformOptions) {
        CsvSchema csvSchema = CsvSchema.emptySchema();
        return (TransformOptions.HEADER_INCLUDED.equals(transformOptions)) ? csvSchema.withHeader() : csvSchema.withoutHeader();
    }

    private String getJsonString(MappingIterator<Map<String,String>> it) {
        System.out.println("Getting JSON String...");
        StringBuilder jsonString = new StringBuilder();
        while (it.hasNext()) {
            try {
                Map<String, String> nextValue = it.nextValue();
                JSONObject jsonObject = new JSONObject();
                jsonObject.putAll(nextValue);
                jsonString.append(jsonObject.toJSONString());

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        System.out.println("json: "+ jsonString);
        return jsonString.toString();
    }
}
