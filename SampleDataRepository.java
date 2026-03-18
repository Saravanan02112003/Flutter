package com.repository;
 
import com.model.SampleData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
 
@Repository
public interface SampleDataRepository extends JpaRepository<SampleData, String> {
}