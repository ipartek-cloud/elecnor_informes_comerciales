using System;
using System.Text.Json;

public class TestDto {
    public decimal ImporteCarteraOferta { get; set; } = 1000;
    public decimal ImporteContratadoOferta { get; set; } = 500;
    public decimal ImporteTotalOferta => ImporteCarteraOferta + ImporteContratadoOferta;
}

class Program {
    static void Main() {
        var dto = new TestDto();
        var json = JsonSerializer.Serialize(dto, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        Console.WriteLine(json);
    }
}
