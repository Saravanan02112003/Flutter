package com.service;
 
import com.model.SampleData;
import com.repository.SampleDataRepository;
import org.springframework.stereotype.Service;
 
import java.util.List;
 
@Service
public class SampleDataService {
 
    private final SampleDataRepository repository;
 
    public SampleDataService(SampleDataRepository repository) {
        this.repository = repository;
    }
 
    public SampleData createSampleData(SampleData sampleData) {
        return repository.save(sampleData);
    }
 
    public List<SampleData> getAllSampleData() {
        return repository.findAll();
    }
 
    public SampleData getSampleDataById(String familyVariantCode) {
        return repository.findById(familyVariantCode).orElse(null);
    }
 
    public SampleData updateSampleData(String id, SampleData sampleData) {
 
        SampleData existing = repository.findById(id).orElse(null);
 
        if (existing != null) {
            existing.setFamilyCode(sampleData.getFamilyCode());
            return repository.save(existing);
        }
 
        return null;
    }
 
    public void deleteSampleData(String id) {
        repository.deleteById(id);
    }
}