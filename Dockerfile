FROM archlinux:base as builder
RUN pacman -Sy --noconfirm jdk11-openjdk unzip && pacman -Scc --noconfirm
ADD https://github.com/GravitLauncher/Launcher/archive/refs/tags/5.1.10.zip .
RUN unzip 5.1.10.zip && rm 5.1.10.zip
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
WORKDIR Launcher-5.1.10
RUN ./gradlew build --debug
WORKDIR Launcher-5.1.10/LaunchServer/build/libs
ADD https://github.com/GravitLauncher/LauncherRuntime/releases/download/v1.5.2/Release.zip .
RUN unzip Release.zip && rm Release.zip
RUN mkdir launcher-modules && mv JavaRuntime-1.5.2.jar ./launcher-modules/
RUN mkdir runtime && mv runtime.zip ./runtime/ && unzip ./runtime/runtime.zip && rm ./runtime/runtime.zip


FROM archlinux:base
WORKDIR app
RUN pacman -Sy --noconfirm jdk11-openjdk unzip && pacman -Scc --noconfirm
ADD https://download2.gluonhq.com/openjfx/11.0.2/openjfx-11.0.2_linux-x64_bin-jmods.zip .
RUN unzip openjfx-11.0.2_linux-x64_bin-jmods.zip && mv javafx-jmods-11.0.2/* /usr/lib/jvm/java-11-openjdk/jmods/ && rmdir javafx-jmods-11.0.2 && rm openjfx-11.0.2_linux-x64_bin-jmods.zip
COPY --from=builder /Launcher-5.1.10/LaunchServer/build/libs ./
COPY updates LaunchServer.json profiles RuntimeLaunchServer.json config ./
EXPOSE 9274:9274
CMD ["/usr/lib/jvm/java-11-openjdk/bin/java", "-javaagent:LaunchServer.jar", "-jar", "LaunchServer.jar"]


