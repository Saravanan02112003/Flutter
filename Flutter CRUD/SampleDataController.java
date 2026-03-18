package com.controller;
 
import com.model.SampleData;
import com.service.SampleDataService;
import org.springframework.web.bind.annotation.*;
 
import java.util.List;
 
@RestController
@RequestMapping("/api/sample-data")
@CrossOrigin
public class SampleDataController {
 
    private final SampleDataService service;
 
    public SampleDataController(SampleDataService service) {
        this.service = service;
    }
 
    @PostMapping
    public SampleData create(@RequestBody SampleData sampleData) {
        return service.createSampleData(sampleData);
    }
 
    @GetMapping
    public List<SampleData> getAll() {
        return service.getAllSampleData();
    }
 
    @GetMapping("/{id}")
    public SampleData getById(@PathVariable String id) {
        return service.getSampleDataById(id);
    }
 
    @PutMapping("/{id}")
    public SampleData update(@PathVariable String id, @RequestBody SampleData sampleData) {
        return service.updateSampleData(id, sampleData);
    }
 
    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        service.deleteSampleData(id);
    }
}