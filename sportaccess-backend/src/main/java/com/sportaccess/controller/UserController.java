package com.sportaccess.controller;

import com.sportaccess.model.User;
import com.sportaccess.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/{firebaseUid}")
    public ResponseEntity<User> getUserByFirebaseUid(@PathVariable String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        User saved = userRepository.save(user);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @PostMapping("/register")
    public ResponseEntity<User> registerOrUpdateUser(@RequestBody Map<String, String> body) {
        String firebaseUid = body.get("firebaseUid");
        String email = body.get("email");
        String nombre = body.getOrDefault("nombre", "Usuario");

        if (firebaseUid == null || firebaseUid.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }

        // BUSQUEDA INTELIGENTE: Por UID o por Email
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseGet(() -> userRepository.findByEmail(email).orElseGet(() -> {
                    User u = new User();
                    u.setFirebaseUid(firebaseUid);
                    u.setEmail(email);
                    return u;
                }));

        user.setFirebaseUid(firebaseUid);
        if (email != null) user.setEmail(email);
        if (nombre != null && !nombre.equals("Usuario")) user.setNombre(nombre);
        
        User saved = userRepository.save(user);
        System.out.println(">>> Sincronización OK: " + email);
        return ResponseEntity.ok(saved);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        if (!userRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        userRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}

