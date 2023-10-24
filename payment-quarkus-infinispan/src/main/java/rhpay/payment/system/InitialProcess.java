package rhpay.payment.system;

import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import org.infinispan.client.hotrod.RemoteCacheManager;
import org.infinispan.commons.configuration.XMLStringConfiguration;

import java.util.Set;

@ApplicationScoped
public class InitialProcess {

    @Inject
    RemoteCacheManager cacheManager;

    @Inject
    public InitialProcess(RemoteCacheManager cacheManager) {
        this.cacheManager = cacheManager;
    }

    private static final String CACHE_CONFIG =
            "<distributed-cache name=\"%s\">"
                    + " <encoding media-type=\"application/x-protostream\"/>"
                    + " <groups enabled=\"true\"/>"
                    + "</distributed-cache>";

    private static final String TRANSACTIONAL_EXPIRED_CACHE_CONFIG =
            "<distributed-cache name=\"%s\">"
                    + " <encoding media-type=\"application/x-protostream\"/>"
                    + " <groups enabled=\"true\"/>"
                    + " <transaction mode=\"BATCH\" locking=\"OPTIMISTIC\"/>"
                    + " <memory max-count=\"100000\" when-full=\"REMOVE\"/>"
                    + "</distributed-cache>";

    private static final String TRANSACTIONAL_CACHE_CONFIG =
            "<distributed-cache name=\"%s\">"
                    + " <encoding media-type=\"application/x-protostream\"/>"
                    + " <groups enabled=\"true\"/>"
                    + " <transaction mode=\"BATCH\" locking=\"OPTIMISTIC\"/>"
                    + "</distributed-cache>";

    void onStart(@Observes StartupEvent ev) {
        Set<String> cacheNames = cacheManager.getCacheNames();
        if (!cacheNames.contains("user")) {
            cacheManager.administration().getOrCreateCache("user", new XMLStringConfiguration(String.format(CACHE_CONFIG, "user")));
            System.out.println("user cache was created");
        }
        if (!cacheNames.contains("wallet")) {
            cacheManager.administration().getOrCreateCache("wallet", new XMLStringConfiguration(String.format(TRANSACTIONAL_CACHE_CONFIG, "wallet")));
            System.out.println("wallet cache was created");
        }
        if (!cacheNames.contains("token")) {
            cacheManager.administration().getOrCreateCache("token", new XMLStringConfiguration(String.format(TRANSACTIONAL_EXPIRED_CACHE_CONFIG, "token")));
            System.out.println("token cache was created");
        }
        if (!cacheNames.contains("payment")) {
            cacheManager.administration().getOrCreateCache("payment", new XMLStringConfiguration(String.format(TRANSACTIONAL_EXPIRED_CACHE_CONFIG, "payment")));
            System.out.println("payment cache was created");
        }
        if (!cacheNames.contains("processing")) {
            cacheManager.administration().getOrCreateCache("processing", new XMLStringConfiguration(String.format(CACHE_CONFIG, "processing")));
            System.out.println("processing cache was created");
        }

    }
}
