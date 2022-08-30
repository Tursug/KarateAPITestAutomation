package examples.petstore;

import com.intuit.karate.junit5.Karate;

public class PetStoreRunner {
    @Karate.Test
    Karate testStore(){
        return Karate.run("petstore").relativeTo(getClass());
    }
}
