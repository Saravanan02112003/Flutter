package com.model;
 
import jakarta.persistence.*;
 
@Entity
@Table(name = "sample_data")
public class SampleData {
 
    @Id
    @Column(name = "family_variant_code")
    private String familyVariantCode;
 
    @Column(name = "family_code")
    private String familyCode;
 
    public SampleData() {}
 
    public SampleData(String familyVariantCode, String familyCode) {
        this.familyVariantCode = familyVariantCode;
        this.familyCode = familyCode;
    }
 
    public String getFamilyVariantCode() {
        return familyVariantCode;
    }
 
    public void setFamilyVariantCode(String familyVariantCode) {
        this.familyVariantCode = familyVariantCode;
    }
 
    public String getFamilyCode() {
        return familyCode;
    }
 
    public void setFamilyCode(String familyCode) {
        this.familyCode = familyCode;
    }
}