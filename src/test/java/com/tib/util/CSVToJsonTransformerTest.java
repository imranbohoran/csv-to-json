package com.tib.util;

import org.junit.Test;
import org.skyscreamer.jsonassert.JSONAssert;

import java.io.File;

public class CSVToJsonTransformerTest {

    @Test
    public void shouldTransformCSVContentToJsonWithHeader() throws Exception {
        String testData = "\"name\",\"age\",\"address line\"\n"+
                "\"imran\",30,\"Some where in the world\"\n"+
                "\"bohoran\", 31, \"Any where in the world\"\n";


        String expected = "{\"name\":\"imran\",\"age\":\"30\",\"address line\":\"Some where in the world\"}," +
                "{\"name\":\"bohoran\",\"age\":\"31\",\"address line\":\"Any where in the world\"}";

        CSVToJsonTransformer csvToJsonTransformer = new CSVToJsonTransformer();
        String actual = csvToJsonTransformer.transform(testData, TransformOptions.HEADER_INCLUDED);

        JSONAssert.assertEquals(expected, actual, false);
    }

    @Test
    public void shouldTransformCSVFileToJsonWithHeader() throws Exception {
        File testFile = new File(this.getClass().getResource("/test_data.csv").toURI());
        String expected = "{\"name\":\"imran\",\"age\":\"30\",\"address line\":\"Some where in the world\"}," +
                "{\"name\":\"bohoran\",\"age\":\"31\",\"address line\":\"Any where in the world\"}";

        CSVToJsonTransformer csvToJsonTransformer = new CSVToJsonTransformer();
        String actual = csvToJsonTransformer.transform(testFile, TransformOptions.HEADER_INCLUDED);
        System.out.println("Actual: "+ actual);
        System.out.println("Expect: "+ expected);

        JSONAssert.assertEquals(expected, actual, false);
    }
}