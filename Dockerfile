FROM yard1/steamcmd_gmail as steamcmd-gmail

FROM yard1/steam_headless
LABEL author="Antoni Baum (Yard1) <antoni.baum@protonmail.com>"
USER root
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-suggests --no-install-recommends \
	python3 xdotool imagemagick xsel xauth xxd x11vnc curl libgtk-3-0 libvulkan1 libvulkan1:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 \
	&& rm -rf /var/lib/apt/lists/*
ARG VNC=1
RUN set -x \
	&& if [ "$VNC" != 0 ]; then \
	apt-get install -y --no-install-suggests --no-install-recommends \
	x11vnc; else apt-get remove --purge -y x11vnc; fi \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*
USER steam
COPY --from=steamcmd-gmail --chown=steam:steam /opt/steamcmd /opt/steamcmd
COPY --from=steamcmd-gmail --chown=steam:steam /steamcmd_gmail /opt/steamcmd_gmail
RUN mkdir -p "/home/steam/.local/share/Paradox Interactive/Hearts of Iron IV/mod"
RUN ln -s "/home/steam/.local/share/Paradox Interactive/Hearts of Iron IV/mod" "/home/steam/mod"
WORKDIR "/home/steam/.local/share/Paradox Interactive/Hearts of Iron IV/"
RUN mkdir -p "/home/steam/.steam/steam/steamapps/common/Hearts of Iron IV"
ARG target="/home/steam/.steam/steam/steamapps/common/Hearts of Iron IV"
ENV DISPLAY :98
RUN /opt/steamcmd/steamcmd.sh +quit
RUN /home/steam/update_steam.sh
RUN /home/steam/update_steam.sh
RUN /home/steam/update_steam.sh
ADD --chown=steam:steam data/hoi4 ${target}
ADD --chown=steam:steam data/appmanifest_394360.acf "/home/steam/.steam/steam/steamapps/"
RUN mkdir /home/steam/image_specimens
ADD --chown=steam:steam image_specimens /home/steam/image_specimens
ADD --chown=steam:steam lib/xdotool_script.sh /home/steam
RUN chmod 755 /home/steam/xdotool_script.sh && sed -i 's/\r$//' /home/steam/xdotool_script.sh
ADD --chown=steam:steam lib/get_steam_guard.py /home/steam
RUN chmod 755 /home/steam/get_steam_guard.py && sed -i 's/\r$//' /home/steam/get_steam_guard.py
USER root
ADD lib/entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh && sed -i 's/\r$//' /entrypoint.sh
EXPOSE 5998
ENV DISPLAY :98
USER steam
ENTRYPOINT [ "/entrypoint.sh" ]
