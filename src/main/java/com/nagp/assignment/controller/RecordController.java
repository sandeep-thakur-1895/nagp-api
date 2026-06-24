package com.nagp.assignment.controller;

import com.nagp.assignment.entity.Record;
import com.nagp.assignment.repository.RecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api")
public class RecordController {

    @Autowired
    private RecordRepository recordRepository;

    @GetMapping("/records")
    public List<Record> getAllRecords() {
        return recordRepository.findAll();
    }
}