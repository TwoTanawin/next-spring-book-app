package com.tanawin.BookAPI.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
@Entity
@Table(name = "books")
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "book_title")
    @NotBlank(message = "Book title is required")
    private String title;

    @Column(name = "book_author")
    @NotBlank(message = "Book author is required")
    private String author;

    @Column(name = "book_description")
    @NotBlank(message = "Book description is required")
    private String description;
}